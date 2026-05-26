"""Auth biznes mantiqi: OTP yuborish/tekshirish, foydalanuvchi yaratish/topish,
tokenlar."""

from __future__ import annotations

import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.logging import get_logger
from app.core.security import (
    create_access_token,
    create_refresh_token,
    hash_otp,
    hash_token,
    verify_otp,
    verify_password,
)
from app.models.auth import AuthOtp, RefreshToken
from app.models.user import User, UserRole

# Admin panel'ga kira oladigan rollar.
ADMIN_LOGIN_ROLES: frozenset[str] = frozenset(
    {UserRole.ADMIN.value, UserRole.MODERATOR.value}
)
from app.services.google_auth import GoogleUserInfo
from app.services.telegram_gateway import (
    SendOtpResult,
    TelegramGatewayClient,
    TelegramGatewayError,
)

logger = get_logger(__name__)


class AuthError(Exception):
    """Auth oqimida user-facing xatolik."""

    def __init__(self, message: str, code: str = "AUTH_ERROR") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class RateLimitError(AuthError):
    pass


def _generate_numeric_code(length: int) -> str:
    """`length` xonali raqamli OTP kod (cryptographically random)."""
    upper = 10**length
    lower = 10 ** (length - 1)
    return str(secrets.randbelow(upper - lower) + lower)


# =====================================================
# Telegram OTP send
# =====================================================


async def send_telegram_otp(
    db: AsyncSession,
    *,
    phone: str,
    gateway: TelegramGatewayClient,
) -> tuple[str, int, str]:
    """OTP yuboradi. Qaytaradi: (request_id, ttl_seconds, delivery_status).

    Rate limit: bir telefonga `RATE_LIMIT_OTP_PER_MINUTE` daqiqada,
    `RATE_LIMIT_OTP_PER_DAY` kuniga.
    """
    # Rate limit tekshiruvi (oddiy DB-asosida; production'da Redis bilan)
    now = datetime.now(UTC)
    minute_ago = now - timedelta(minutes=1)
    day_ago = now - timedelta(days=1)

    last_minute_count_q = select(AuthOtp).where(
        AuthOtp.phone == phone, AuthOtp.created_at >= minute_ago
    )
    last_day_count_q = select(AuthOtp).where(
        AuthOtp.phone == phone, AuthOtp.created_at >= day_ago
    )
    last_minute = (await db.scalars(last_minute_count_q)).all()
    last_day = (await db.scalars(last_day_count_q)).all()

    if len(last_minute) >= settings.rate_limit_otp_per_minute:
        raise RateLimitError("Tez-tez urinish. 1 daqiqadan keyin qayta urinib ko'ring.", "RATE_LIMIT")
    if len(last_day) >= settings.rate_limit_otp_per_day:
        raise RateLimitError("Kunlik limitga yetdingiz. Ertaga qayta urinib ko'ring.", "RATE_LIMIT_DAILY")

    # OTP generatsiya va Telegram'ga yuborish
    code = _generate_numeric_code(settings.telegram_otp_length)
    ttl = settings.telegram_otp_ttl_seconds

    if not gateway.is_configured:
        # Dev rejim: OTP'ni log'ga chiqaramiz, Telegram'ga yubormaymiz
        logger.warning("[DEV] Telegram Gateway not configured. OTP for %s: %s", phone, code)
        result = SendOtpResult(request_id=f"dev-{secrets.token_hex(8)}",
                               delivery_status="dev", is_test=True)
    else:
        try:
            result = await gateway.send_verification_message(
                phone, code=code, ttl=ttl
            )
        except TelegramGatewayError as e:
            logger.error("Telegram Gateway send failed: %s", e)
            raise AuthError("OTP yuborishda xatolik. Keyinroq urinib ko'ring.", "GATEWAY_ERROR") from e

    # DB'ga saqlash
    otp = AuthOtp(
        phone=phone,
        code_hash=hash_otp(code),
        request_id=result.request_id,
        expires_at=now + timedelta(seconds=ttl),
    )
    db.add(otp)
    await db.commit()

    return result.request_id, ttl, result.delivery_status


# =====================================================
# Telegram OTP verify
# =====================================================


async def verify_telegram_otp(
    db: AsyncSession,
    *,
    phone: str,
    code: str,
) -> User:
    """OTP'ni tekshiradi. To'g'ri bo'lsa user yaratadi/topadi va qaytaradi."""
    now = datetime.now(UTC)

    # Eng yangi OTP yozuvi
    stmt = (
        select(AuthOtp)
        .where(
            AuthOtp.phone == phone,
            AuthOtp.verified.is_(False),
            AuthOtp.expires_at > now,
        )
        .order_by(AuthOtp.created_at.desc())
        .limit(1)
    )
    otp = (await db.scalars(stmt)).first()
    if otp is None:
        raise AuthError("OTP topilmadi yoki muddati o'tgan", "OTP_NOT_FOUND")

    if otp.attempts >= settings.telegram_otp_max_attempts:
        raise AuthError("Maksimal urinishdan o'tdingiz. Yangi OTP so'rang.", "OTP_LOCKED")

    otp.attempts += 1

    if not verify_otp(code, otp.code_hash):
        await db.commit()
        raise AuthError("OTP noto'g'ri", "OTP_INVALID")

    otp.verified = True

    # User yaratish yoki topish
    user_stmt = select(User).where(User.phone == phone)
    user = (await db.scalars(user_stmt)).first()
    if user is None:
        user = User(
            phone=phone,
            fullname="Foydalanuvchi",  # ro'yxatdan o'tish ekrani'da yangilanadi
            role=UserRole.USER.value,
        )
        db.add(user)

    user.last_login_at = now
    await db.commit()
    await db.refresh(user)
    return user


# =====================================================
# Admin panel login (email/phone + password)
# =====================================================


async def admin_login(
    db: AsyncSession,
    *,
    identifier: str,
    password: str,
) -> User:
    """Email yoki telefon + parol orqali admin/moderator kiritadi.

    - Reaktiv user'lar (USER role) admin panelga kira olmaydi.
    - Bloklangan foydalanuvchilar — 401.
    - Vaqt-tezligini saqlash uchun password tekshiruvi har doim bcrypt
      orqali bajariladi (user topilmasa ham), shu sababli aniq xato sababi
      (user yoki parol) timing-attack orqali ajratilmaydi.
    """
    raw = identifier.strip()
    if not raw:
        raise AuthError("Email yoki telefon kiritilmagan", "INVALID_IDENTIFIER")

    # Email mi yoki telefonmi aniqlaymiz
    is_email = "@" in raw
    user: User | None = None
    if is_email:
        stmt = select(User).where(User.email == raw.lower())
    else:
        stmt = select(User).where(User.phone == raw)
    user = (await db.scalars(stmt)).first()

    # Timing-attack himoyasi: user topilmasa ham bcrypt verify chaqiramiz
    # (dummy hash; bu hech qachon mos kelmaydi).
    dummy_hash = (
        "$2b$12$CwTycUXWue0Thq9StjUM0u"
        "J8.OOf6P4yKxNHkPjV9aJjLkY3.lQpa"  # bcrypt 60-char dummy
    )
    password_hash = (
        user.password_hash if user and user.password_hash else dummy_hash
    )
    password_ok = verify_password(password, password_hash)

    if not user or not user.password_hash or not password_ok:
        raise AuthError("Email/telefon yoki parol noto'g'ri", "INVALID_CREDENTIALS")

    if user.is_banned:
        raise AuthError("Foydalanuvchi bloklangan", "USER_BANNED")

    if user.role not in ADMIN_LOGIN_ROLES:
        raise AuthError(
            "Sizda admin panelga kirish huquqi yo'q",
            "FORBIDDEN_ROLE",
        )

    user.last_login_at = datetime.now(UTC)
    await db.commit()
    await db.refresh(user)
    return user


# =====================================================
# Google sign-in
# =====================================================


async def upsert_google_user(
    db: AsyncSession,
    info: GoogleUserInfo,
) -> User:
    """Google foydalanuvchisini topadi yoki yaratadi."""
    stmt = select(User).where(User.google_sub == info.sub)
    user = (await db.scalars(stmt)).first()

    if user is None:
        # Email bo'yicha mavjud user'ni Google'ga ulash
        email_stmt = select(User).where(User.email == info.email)
        user = (await db.scalars(email_stmt)).first()

    now = datetime.now(UTC)
    if user is None:
        user = User(
            email=info.email,
            google_sub=info.sub,
            fullname=info.name,
            img_url=info.picture,
            language=(info.locale or "uz")[:2],
            role=UserRole.USER.value,
        )
        db.add(user)
    else:
        # Mavjud user'ni yangilash
        if not user.google_sub:
            user.google_sub = info.sub
        if not user.img_url and info.picture:
            user.img_url = info.picture

    user.last_login_at = now
    await db.commit()
    await db.refresh(user)
    return user


# =====================================================
# Token issue / refresh / revoke
# =====================================================


async def issue_token_pair(
    db: AsyncSession,
    user: User,
    *,
    user_agent: str | None = None,
    ip_address: str | None = None,
) -> tuple[str, str, datetime]:
    """Access + refresh token chiqaradi va refreshni DB'ga yozadi."""
    access_token, expires_at = create_access_token(user.id, role=user.role)
    refresh_token, refresh_expires = create_refresh_token(user.id)

    db.add(
        RefreshToken(
            user_id=user.id,
            token_hash=hash_token(refresh_token),
            expires_at=refresh_expires,
            user_agent=user_agent,
            ip_address=ip_address,
        )
    )
    await db.commit()
    return access_token, refresh_token, expires_at


async def refresh_access_token(
    db: AsyncSession,
    refresh_token: str,
) -> tuple[User, str, datetime]:
    """Refresh tokenni tekshiradi va yangi access token chiqaradi."""
    token_hash = hash_token(refresh_token)
    now = datetime.now(UTC)

    stmt = select(RefreshToken).where(
        RefreshToken.token_hash == token_hash,
        RefreshToken.revoked_at.is_(None),
        RefreshToken.expires_at > now,
    )
    record = (await db.scalars(stmt)).first()
    if record is None:
        raise AuthError("Refresh token yaroqsiz", "REFRESH_INVALID")

    user = await db.get(User, record.user_id)
    if user is None or user.is_banned:
        raise AuthError("Foydalanuvchi mavjud emas yoki bloklangan", "USER_INVALID")

    access_token, expires_at = create_access_token(user.id, role=user.role)
    return user, access_token, expires_at


async def revoke_refresh_token(db: AsyncSession, refresh_token: str) -> None:
    """Logout — refresh tokenni invalidatsiya qiladi."""
    token_hash = hash_token(refresh_token)
    await db.execute(
        update(RefreshToken)
        .where(RefreshToken.token_hash == token_hash, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=datetime.now(UTC))
    )
    await db.commit()


async def revoke_all_user_tokens(db: AsyncSession, user_id: UUID) -> None:
    """Admin: foydalanuvchining barcha session'larini bekor qilish."""
    await db.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == user_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=datetime.now(UTC))
    )
    await db.commit()
