"""JWT va parol xeshlash yordamchilari."""

from __future__ import annotations

import hashlib
import secrets
from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import UUID

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ===== Parol xeshlash (admin login uchun, kelajak) =====


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


# ===== OTP kod xeshlash =====


def hash_otp(code: str) -> str:
    """OTP kodni bcrypt orqali xeshlaydi (DB'da saqlash uchun)."""
    return pwd_context.hash(code)


def verify_otp(code: str, hashed: str) -> bool:
    return pwd_context.verify(code, hashed)


# ===== Refresh token xeshlash =====


def hash_token(token: str) -> str:
    """Refresh tokenning SHA-256 xeshi (DB'da saqlash uchun)."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def generate_secure_token(length_bytes: int = 32) -> str:
    """URL-safe random token generatsiya qiladi."""
    return secrets.token_urlsafe(length_bytes)


# ===== JWT =====


class TokenType:
    ACCESS = "access"
    REFRESH = "refresh"


def create_access_token(
    subject: str | UUID,
    role: str,
    extra_claims: dict[str, Any] | None = None,
) -> tuple[str, datetime]:
    """JWT access token yaratadi va token + expire datetime qaytaradi."""
    expire = datetime.now(UTC) + timedelta(minutes=settings.jwt_access_expire_minutes)
    claims: dict[str, Any] = {
        "sub": str(subject),
        "role": role,
        "type": TokenType.ACCESS,
        "exp": expire,
        "iat": datetime.now(UTC),
    }
    if extra_claims:
        claims.update(extra_claims)
    token = jwt.encode(claims, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)
    return token, expire


def create_refresh_token(subject: str | UUID) -> tuple[str, datetime]:
    """Refresh token (random URL-safe string) + expire datetime."""
    token = generate_secure_token(32)
    expire = datetime.now(UTC) + timedelta(days=settings.jwt_refresh_expire_days)
    return token, expire


def decode_access_token(token: str) -> dict[str, Any]:
    """JWT'ni dekod qiladi. Yaroqsiz bo'lsa `JWTError` tashlaydi."""
    payload: dict[str, Any] = jwt.decode(
        token,
        settings.jwt_secret_key,
        algorithms=[settings.jwt_algorithm],
    )
    if payload.get("type") != TokenType.ACCESS:
        raise JWTError("Invalid token type")
    return payload


__all__ = [
    "TokenType",
    "create_access_token",
    "create_refresh_token",
    "decode_access_token",
    "generate_secure_token",
    "hash_otp",
    "hash_password",
    "hash_token",
    "verify_otp",
    "verify_password",
]
