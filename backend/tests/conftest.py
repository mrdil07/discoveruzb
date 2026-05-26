"""Test infratuzilmasi — pytest fixtures.

Test DB: alohida PostgreSQL DB ishlatiladi (`TEST_DATABASE_URL` env yoki
default `postgresql+asyncpg://discoveruzb:discoveruzb@localhost:5432/discoveruzb_test`).

Har test funktsiyasi nested savepoint ichida ishlaydi va oxirida
rollback qilinadi — testlar bir-biriga ta'sir qilmaydi.
"""

from __future__ import annotations

import os
from collections.abc import AsyncGenerator
from typing import Any
from uuid import uuid4

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.pool import NullPool

# ===== Env override (settings'ni yaratishdan oldin bo'lishi kerak) =====

os.environ.setdefault(
    "TEST_DATABASE_URL",
    "postgresql+asyncpg://discoveruzb:discoveruzb@localhost:5432/discoveruzb_test",
)
os.environ["DATABASE_URL"] = os.environ["TEST_DATABASE_URL"]
os.environ.setdefault("REDIS_URL", "redis://localhost:6379/15")
os.environ.setdefault("SECRET_KEY", "test-secret-key-32-bytes-minimum-length-padding")
os.environ.setdefault("JWT_SECRET_KEY", "test-jwt-secret-32-bytes-minimum-length-padding")
os.environ.setdefault("APP_ENV", "development")
os.environ.setdefault("DEBUG", "false")
os.environ.setdefault("TELEGRAM_GATEWAY_TOKEN", "")  # dev rejim — OTP logga chiqadi
os.environ.setdefault("GOOGLE_CLIENT_ID_WEB", "test.apps.googleusercontent.com")
os.environ.setdefault("MINIO_ENDPOINT", "localhost:9000")
os.environ.setdefault("MINIO_ACCESS_KEY", "minioadmin")
os.environ.setdefault("MINIO_SECRET_KEY", "minioadmin")
os.environ.setdefault("RATE_LIMIT_OTP_PER_MINUTE", "100")  # testlarda limit oshirilgan
os.environ.setdefault("RATE_LIMIT_OTP_PER_DAY", "1000")

# ===== App import (env o'rnatilgandan keyin) =====

from app.core.config import settings  # noqa: E402
from app.core.security import create_access_token  # noqa: E402
from app.db.session import get_db  # noqa: E402
from app.main import create_app  # noqa: E402
from app.models import Base, User, UserRole  # noqa: E402

TEST_DB_URL = settings.database_url


# =====================================================
# Engine va DB session fixtures
# =====================================================


@pytest.fixture(scope="session")
def event_loop():
    """Session-scope event loop — barcha async fixturelar bir loopda."""
    import asyncio

    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture(scope="session")
async def db_engine():
    """Test session davomida bitta engine.

    `NullPool` — har so'rovda yangi connection (event loop conflict'lar
    oldini oladi, async test framework'lar uchun standart pattern).
    """
    engine = create_async_engine(
        str(TEST_DB_URL),
        echo=False,
        future=True,
        poolclass=NullPool,
    )

    async with engine.begin() as conn:
        # Extensions (pgcrypto = gen_random_uuid; pg_trgm = trigram search)
        from sqlalchemy import text

        await conn.execute(text('CREATE EXTENSION IF NOT EXISTS "pgcrypto"'))
        await conn.execute(text('CREATE EXTENSION IF NOT EXISTS "pg_trgm"'))
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
        # Trigram index (alembic'da bor, lekin metadata.create_all'da yo'q)
        await conn.execute(text(
            "CREATE INDEX IF NOT EXISTS ix_posts_name_trgm "
            "ON posts USING gin (place_name gin_trgm_ops)"
        ))

    yield engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest_asyncio.fixture
async def db_session(db_engine) -> AsyncGenerator[AsyncSession, None]:
    """Har test uchun yangi engine + sessionmaker.

    `NullPool` ishlatilgani uchun har so'rovda yangi connection. Cleanup
    avval truncate qiladi va session'ni yopadi — loop conflict yo'q.
    """
    from sqlalchemy import text

    # Avval clean state — testdan oldin tozalash
    async with db_engine.begin() as conn:
        await conn.execute(text(
            "TRUNCATE TABLE "
            "place_fetch_logs, external_reviews, "
            "refresh_tokens, auth_otps, post_likes, post_saves, comments, "
            "galleries, posts, categories, users "
            "RESTART IDENTITY CASCADE"
        ))

    SessionLocal = async_sessionmaker(db_engine, expire_on_commit=False)
    session = SessionLocal()
    try:
        yield session
    finally:
        await session.close()


# =====================================================
# FastAPI app + httpx client
# =====================================================


@pytest_asyncio.fixture
async def client(db_engine) -> AsyncGenerator[AsyncClient, None]:
    """`AsyncClient` — backend'ga ASGI orqali murojaat qiladi.

    Har so'rov uchun yangi session yaratiladi (`get_db` override).
    Test fixture'ining `db_session`'idan alohida — HTTP request va test
    yozish/o'qish bir-biriga ta'sir qilmaydi (alohida connection'lar,
    PostgreSQL READ COMMITTED).
    """
    app = create_app()
    SessionLocal = async_sessionmaker(db_engine, expire_on_commit=False)

    async def _override_get_db() -> AsyncGenerator[AsyncSession, None]:
        async with SessionLocal() as session:
            yield session

    app.dependency_overrides[get_db] = _override_get_db

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()


# =====================================================
# User fixtures
# =====================================================


_phone_counter = {"n": 0}


def _fake_uz_phone() -> str:
    """Test uchun yaroqli E.164 O'zbek raqami."""
    _phone_counter["n"] += 1
    n = _phone_counter["n"]
    return f"+99890{1000000 + n:07d}"


async def _create_user(
    db: AsyncSession,
    *,
    role: str = UserRole.USER.value,
    phone: str | None = None,
    email: str | None = None,
    fullname: str | None = None,
) -> User:
    user = User(
        phone=phone if phone is not None else _fake_uz_phone(),
        email=email,
        fullname=fullname or f"Test User {uuid4().hex[:4]}",
        role=role,
        language="uz",
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@pytest_asyncio.fixture
async def normal_user(db_session: AsyncSession) -> User:
    return await _create_user(db_session)


@pytest_asyncio.fixture
async def admin_user(db_session: AsyncSession) -> User:
    return await _create_user(
        db_session,
        role=UserRole.ADMIN.value,
        fullname="Admin User",
    )


@pytest_asyncio.fixture
async def moderator_user(db_session: AsyncSession) -> User:
    return await _create_user(
        db_session,
        role=UserRole.MODERATOR.value,
        fullname="Moderator User",
    )


def auth_headers(user: User) -> dict[str, str]:
    """JWT bilan `Authorization` header."""
    token, _ = create_access_token(user.id, role=user.role)
    return {"Authorization": f"Bearer {token}"}


# =====================================================
# External service mocks
# =====================================================


@pytest.fixture
def mock_telegram_gateway(monkeypatch):
    """Telegram Gateway'ni real HTTP chaqirmasdan stub qiladi.

    `_token` bo'sh bo'lsa, service o'zi dev rejimga o'tadi — bizning
    auth oqim shuni ishlatadi (OTP DB'da xeshlanib saqlanadi).
    """
    # `is_configured` `False` qaytsa, sendOtp dev rejimda ishlaydi
    from app.services import telegram_gateway

    monkeypatch.setattr(
        telegram_gateway.TelegramGatewayClient,
        "is_configured",
        property(lambda self: False),
    )


@pytest.fixture
def mock_google_auth(monkeypatch):
    """`verify_google_id_token`'ni stub qiladi —
    test ID token → fixed GoogleUserInfo qaytaradi.
    """
    from app.services import google_auth

    def _stub(id_token: str):
        if id_token.startswith("invalid"):
            raise google_auth.GoogleAuthError("Invalid token")
        return google_auth.GoogleUserInfo(
            sub=f"google-sub-{id_token[:8]}",
            email=f"{id_token[:8]}@example.com",
            email_verified=True,
            name=f"Google User {id_token[:4]}",
            picture="https://lh3.googleusercontent.com/test.jpg",
            locale="uz",
        )

    # 2 joyda ishlatiladi — `google_auth` modulida va `auth.py` router'da
    monkeypatch.setattr(google_auth, "verify_google_id_token", _stub)
    monkeypatch.setattr("app.api.v1.auth.verify_google_id_token", _stub)


@pytest.fixture
def mock_storage(monkeypatch):
    """MinIO storage'ni stub qiladi — fayl yuklamaydi, fake URL qaytaradi."""
    from app.services import storage as storage_module

    class FakeStorage:
        is_configured = True

        def ensure_buckets(self) -> None:
            pass

        async def upload_image(
            self,
            *,
            data: bytes,
            content_type: str,
            folder: str,
            bucket: str | None = None,
        ):
            return storage_module.UploadResult(
                key=f"{folder}/test-{uuid4().hex[:8]}.webp",
                url=f"http://test-minio/{folder}/test.webp",
                size_bytes=len(data),
                content_type="image/webp",
            )

        def delete(self, key: str, *, bucket: str | None = None) -> bool:
            return True

        def presigned_get(self, key: str, *, hours: int = 1) -> str:
            return f"http://test-minio/private/{key}?token=fake"

    monkeypatch.setattr(storage_module, "get_storage", lambda: FakeStorage())


# =====================================================
# Helper: bypass real Telegram OTP — DB'dagi OTP kodni return qil
# =====================================================


async def get_latest_otp_for_phone(db: AsyncSession, phone: str) -> str | None:
    """Test'larda OTP'ni DB'dan olib, bcrypt-verify uchun reverse'lab
    bo'lmaydi. Shuning uchun OTP yuborgandan keyin xeshlangan kod'ni
    `code` bilan tekshirish kerak emas — buning o'rniga test rejimda
    `OTPViewModel`'ga maxsus token kiritamiz.

    Lekin backend'da bunday mexanizm yo'q. Shuning uchun unit test'larda
    biz to'g'ridan-to'g'ri `auth_service`'ni chaqirib OTP'ni inject qilamiz
    yoki mock orqali bypass qilamiz. Bu yordamchi function — kelajak.
    """
    from sqlalchemy import select

    from app.models.auth import AuthOtp

    stmt = (
        select(AuthOtp.code_hash)
        .where(AuthOtp.phone == phone)
        .order_by(AuthOtp.created_at.desc())
        .limit(1)
    )
    result = await db.scalar(stmt)
    return result
