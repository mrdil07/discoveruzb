"""Auth router — Telegram Gateway, Google, refresh, logout."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Request, status

from app.api.deps import CurrentUser, DbSession
from app.schemas.auth import (
    AdminLoginRequest,
    GoogleSignInRequest,
    LogoutRequest,
    RefreshRequest,
    TelegramSendOtpRequest,
    TelegramSendOtpResponse,
    TelegramVerifyOtpRequest,
    TokenPair,
)
from app.schemas.common import MessageResponse
from app.schemas.user import UserMe
from app.services import auth as auth_service
from app.services.auth import AuthError, RateLimitError
from app.services.google_auth import GoogleAuthError, verify_google_id_token
from app.services.recaptcha import (
    RecaptchaError,
    RecaptchaVerifier,
    get_recaptcha_verifier,
)
from app.services.telegram_gateway import TelegramGatewayClient, get_telegram_gateway

router = APIRouter(prefix="/auth", tags=["auth"])


def _client_meta(request: Request) -> tuple[str | None, str | None]:
    user_agent = request.headers.get("user-agent")
    ip = request.client.host if request.client else None
    return user_agent, ip


@router.post(
    "/telegram/send-otp",
    response_model=TelegramSendOtpResponse,
    summary="Telegram Gateway orqali OTP yuborish",
)
async def telegram_send_otp(
    payload: TelegramSendOtpRequest,
    db: DbSession,
    gateway: Annotated[TelegramGatewayClient, Depends(get_telegram_gateway)],
) -> TelegramSendOtpResponse:
    try:
        request_id, ttl, delivery = await auth_service.send_telegram_otp(
            db, phone=payload.phone, gateway=gateway
        )
    except RateLimitError as e:
        raise HTTPException(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail=e.message) from e
    except AuthError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=e.message) from e
    return TelegramSendOtpResponse(request_id=request_id, expires_in=ttl, delivery=delivery)


@router.post(
    "/telegram/verify-otp",
    response_model=TokenPair,
    summary="OTP tekshirish va JWT chiqarish",
)
async def telegram_verify_otp(
    payload: TelegramVerifyOtpRequest,
    request: Request,
    db: DbSession,
) -> TokenPair:
    try:
        user = await auth_service.verify_telegram_otp(
            db, phone=payload.phone, code=payload.code
        )
    except AuthError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=e.message) from e

    user_agent, ip = _client_meta(request)
    access, refresh, expires_at = await auth_service.issue_token_pair(
        db, user, user_agent=user_agent, ip_address=ip
    )
    return TokenPair(
        access_token=access,
        refresh_token=refresh,
        expires_at=expires_at,
        user=UserMe.model_validate(user),
    )


@router.post(
    "/admin/login",
    response_model=TokenPair,
    summary="Admin panel: email/telefon + parol + reCAPTCHA bilan kirish",
)
async def admin_login(
    payload: AdminLoginRequest,
    request: Request,
    db: DbSession,
    recaptcha: Annotated[RecaptchaVerifier, Depends(get_recaptcha_verifier)],
) -> TokenPair:
    user_agent, ip = _client_meta(request)

    # 1) reCAPTCHA tekshiruvi (dev rejimda secret bo'sh bo'lsa skip)
    try:
        await recaptcha.verify(
            payload.recaptcha_token,
            remote_ip=ip,
            expected_action="admin_login",
        )
    except RecaptchaError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"reCAPTCHA tekshiruvidan o'tmadi: {e.reason}",
        ) from e

    # 2) Email/telefon + parol
    try:
        user = await auth_service.admin_login(
            db, identifier=payload.identifier, password=payload.password
        )
    except AuthError as e:
        # Role taqiqi — 403, qolganlari — 401
        code = (
            status.HTTP_403_FORBIDDEN
            if e.code == "FORBIDDEN_ROLE"
            else status.HTTP_401_UNAUTHORIZED
        )
        raise HTTPException(status_code=code, detail=e.message) from e

    access, refresh, expires_at = await auth_service.issue_token_pair(
        db, user, user_agent=user_agent, ip_address=ip
    )
    return TokenPair(
        access_token=access,
        refresh_token=refresh,
        expires_at=expires_at,
        user=UserMe.model_validate(user),
    )


@router.post(
    "/google",
    response_model=TokenPair,
    summary="Google ID token bilan kirish",
)
async def google_sign_in(
    payload: GoogleSignInRequest,
    request: Request,
    db: DbSession,
) -> TokenPair:
    try:
        info = verify_google_id_token(payload.id_token)
    except GoogleAuthError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e)) from e

    user = await auth_service.upsert_google_user(db, info)
    user_agent, ip = _client_meta(request)
    access, refresh, expires_at = await auth_service.issue_token_pair(
        db, user, user_agent=user_agent, ip_address=ip
    )
    return TokenPair(
        access_token=access,
        refresh_token=refresh,
        expires_at=expires_at,
        user=UserMe.model_validate(user),
    )


@router.post(
    "/refresh",
    response_model=TokenPair,
    summary="Refresh token bilan yangi access token",
)
async def refresh_token_endpoint(
    payload: RefreshRequest,
    db: DbSession,
) -> TokenPair:
    try:
        user, access, expires_at = await auth_service.refresh_access_token(
            db, payload.refresh_token
        )
    except AuthError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=e.message) from e
    return TokenPair(
        access_token=access,
        refresh_token=payload.refresh_token,  # bir xil refresh, faqat access yangilanadi
        expires_at=expires_at,
        user=UserMe.model_validate(user),
    )


@router.post(
    "/logout",
    response_model=MessageResponse,
    summary="Refresh tokenni invalidatsiya qilish",
)
async def logout(payload: LogoutRequest, db: DbSession) -> MessageResponse:
    await auth_service.revoke_refresh_token(db, payload.refresh_token)
    return MessageResponse(message="Tizimdan chiqildi")


@router.get(
    "/me",
    response_model=UserMe,
    summary="Joriy foydalanuvchi profili",
)
async def me(user: CurrentUser) -> UserMe:
    return UserMe.model_validate(user)
