"""Auth oqim testlari — Telegram OTP, Google, refresh, logout, me.

Telegram OTP testlari: dev rejimda (`TELEGRAM_GATEWAY_TOKEN=''`)
backend OTP'ni logga chiqaradi va DB'da bcrypt-xeshlab saqlaydi.
Real kod'ni testdan olib bo'lmaydi (bcrypt one-way), shuning uchun
verify uchun `_inject_otp` helper bilan ma'lum kod kiritamiz.
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_otp
from app.models.auth import AuthOtp


async def _inject_otp(
    db: AsyncSession,
    phone: str,
    code: str = "123456",
    ttl_seconds: int = 300,
) -> AuthOtp:
    """Test uchun OTP'ni to'g'ridan-to'g'ri DB ga qo'yadi.

    Real oqim: `POST /auth/telegram/send-otp` Telegram'ga yuboradi va
    OTP DB'da xeshlanadi. Testda biz ma'lum bir kod (`123456`) bilan
    yangi yozuv yaratamiz, keyin `verify-otp`'ga shu kod bilan murojaat.
    """
    otp = AuthOtp(
        phone=phone,
        code_hash=hash_otp(code),
        request_id=f"test-{phone[-4:]}",
        expires_at=datetime.now(UTC) + timedelta(seconds=ttl_seconds),
    )
    db.add(otp)
    await db.commit()
    return otp


# =====================================================
# Telegram OTP — send
# =====================================================


class TestTelegramSendOtp:
    @pytest.mark.asyncio
    async def test_send_otp_success(
        self, client: AsyncClient, mock_telegram_gateway
    ):
        response = await client.post(
            "/api/v1/auth/telegram/send-otp",
            json={"phone": "+998901234567"},
        )
        assert response.status_code == 200, response.text
        body = response.json()
        assert "request_id" in body
        assert body["expires_in"] > 0
        assert body["delivery"] in ("dev", "telegram", "sms", "unknown", "sent")

    @pytest.mark.asyncio
    async def test_send_otp_invalid_phone(self, client: AsyncClient):
        response = await client.post(
            "/api/v1/auth/telegram/send-otp",
            json={"phone": "abc123"},
        )
        assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_send_otp_normalizes_phone(
        self, client: AsyncClient, mock_telegram_gateway, db_session: AsyncSession
    ):
        await client.post(
            "/api/v1/auth/telegram/send-otp",
            json={"phone": "+998901234567"},
        )
        # DB'da phone E.164 formatda
        otp = (await db_session.scalars(select(AuthOtp))).first()
        assert otp is not None
        assert otp.phone == "+998901234567"


# =====================================================
# Telegram OTP — verify
# =====================================================


class TestTelegramVerifyOtp:
    @pytest.mark.asyncio
    async def test_verify_otp_creates_new_user(
        self, client: AsyncClient, db_session: AsyncSession
    ):
        phone = "+998901111111"
        await _inject_otp(db_session, phone, "111222")

        response = await client.post(
            "/api/v1/auth/telegram/verify-otp",
            json={"phone": phone, "code": "111222"},
        )
        assert response.status_code == 200, response.text
        body = response.json()
        assert body["token_type"] == "bearer"
        assert body["access_token"]
        assert body["refresh_token"]
        assert body["user"]["phone"] == phone
        assert body["user"]["role"] == "user"

    @pytest.mark.asyncio
    async def test_verify_otp_wrong_code(
        self, client: AsyncClient, db_session: AsyncSession
    ):
        phone = "+998902222222"
        await _inject_otp(db_session, phone, "111222")

        response = await client.post(
            "/api/v1/auth/telegram/verify-otp",
            json={"phone": phone, "code": "000000"},
        )
        assert response.status_code == 401
        assert "OTP" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_verify_otp_no_otp_sent(self, client: AsyncClient):
        response = await client.post(
            "/api/v1/auth/telegram/verify-otp",
            json={"phone": "+998903333333", "code": "123456"},
        )
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_verify_otp_expired(
        self, client: AsyncClient, db_session: AsyncSession
    ):
        phone = "+998904444444"
        otp = AuthOtp(
            phone=phone,
            code_hash=hash_otp("123456"),
            expires_at=datetime.now(UTC) - timedelta(seconds=1),
        )
        db_session.add(otp)
        await db_session.commit()

        response = await client.post(
            "/api/v1/auth/telegram/verify-otp",
            json={"phone": phone, "code": "123456"},
        )
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_verify_otp_returns_existing_user(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        phone = normal_user.phone
        await _inject_otp(db_session, phone, "333444")

        response = await client.post(
            "/api/v1/auth/telegram/verify-otp",
            json={"phone": phone, "code": "333444"},
        )
        assert response.status_code == 200
        body = response.json()
        assert body["user"]["id"] == str(normal_user.id)


# =====================================================
# Google sign-in
# =====================================================


class TestGoogleSignIn:
    @pytest.mark.asyncio
    async def test_google_creates_new_user(
        self, client: AsyncClient, mock_google_auth
    ):
        response = await client.post(
            "/api/v1/auth/google",
            json={"id_token": "abc12345-fake-token"},
        )
        assert response.status_code == 200, response.text
        body = response.json()
        assert body["user"]["email"] == "abc12345@example.com"
        assert body["access_token"]

    @pytest.mark.asyncio
    async def test_google_invalid_token(
        self, client: AsyncClient, mock_google_auth
    ):
        # Min 10 belgi (Pydantic), mock `invalid` prefix bilan reject qiladi
        response = await client.post(
            "/api/v1/auth/google",
            json={"id_token": "invalid-bad-token"},
        )
        assert response.status_code == 401


# =====================================================
# Refresh & logout & me
# =====================================================


class TestRefreshAndLogout:
    @pytest.mark.asyncio
    async def test_refresh_returns_new_access(
        self, client: AsyncClient, mock_google_auth
    ):
        login = await client.post(
            "/api/v1/auth/google",
            json={"id_token": "user1234-fake"},
        )
        refresh = login.json()["refresh_token"]

        response = await client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh},
        )
        assert response.status_code == 200
        assert response.json()["access_token"]

    @pytest.mark.asyncio
    async def test_refresh_invalid_token(self, client: AsyncClient):
        response = await client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": "not-a-real-token"},
        )
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_logout_invalidates_refresh(
        self, client: AsyncClient, mock_google_auth
    ):
        login = await client.post(
            "/api/v1/auth/google",
            json={"id_token": "user5678-fake"},
        )
        refresh = login.json()["refresh_token"]

        # Logout
        await client.post(
            "/api/v1/auth/logout",
            json={"refresh_token": refresh},
        )

        # Refresh endi ishlamasligi kerak
        response = await client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh},
        )
        assert response.status_code == 401


class TestMe:
    @pytest.mark.asyncio
    async def test_me_returns_current_user(
        self, client: AsyncClient, normal_user
    ):
        from tests.conftest import auth_headers

        response = await client.get(
            "/api/v1/auth/me",
            headers=auth_headers(normal_user),
        )
        assert response.status_code == 200
        body = response.json()
        assert body["id"] == str(normal_user.id)
        assert body["fullname"] == normal_user.fullname

    @pytest.mark.asyncio
    async def test_me_without_token_returns_401(self, client: AsyncClient):
        response = await client.get("/api/v1/auth/me")
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_me_with_invalid_token_returns_401(self, client: AsyncClient):
        response = await client.get(
            "/api/v1/auth/me",
            headers={"Authorization": "Bearer invalid-token"},
        )
        assert response.status_code == 401
