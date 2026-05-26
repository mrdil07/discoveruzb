"""Auth Pydantic schema'lari."""

from __future__ import annotations

from datetime import datetime

import phonenumbers
from pydantic import BaseModel, Field, field_validator

from app.schemas.user import UserMe


def _normalize_phone(value: str) -> str:
    """E.164 formatga keltiradi (`+998901234567`)."""
    try:
        parsed = phonenumbers.parse(value, None)
    except phonenumbers.NumberParseException as e:
        raise ValueError("Telefon raqami noto'g'ri") from e
    if not phonenumbers.is_valid_number(parsed):
        raise ValueError("Telefon raqami yaroqli emas")
    return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)


class TelegramSendOtpRequest(BaseModel):
    phone: str = Field(min_length=8, max_length=32)

    @field_validator("phone", mode="after")
    @classmethod
    def normalize(cls, v: str) -> str:
        return _normalize_phone(v)


class TelegramSendOtpResponse(BaseModel):
    request_id: str
    expires_in: int = Field(description="OTP TTL soniyalarda")
    delivery: str = Field(description="telegram | sms | unknown")


class TelegramVerifyOtpRequest(BaseModel):
    phone: str
    code: str = Field(min_length=4, max_length=8)

    @field_validator("phone", mode="after")
    @classmethod
    def normalize(cls, v: str) -> str:
        return _normalize_phone(v)


class GoogleSignInRequest(BaseModel):
    id_token: str = Field(min_length=10)


class AdminLoginRequest(BaseModel):
    """Admin panel login: email yoki telefon + parol + reCAPTCHA tokeni."""

    identifier: str = Field(
        min_length=3,
        max_length=255,
        description="Email manzili yoki E.164 telefon raqami",
    )
    password: str = Field(min_length=6, max_length=128)
    recaptcha_token: str = Field(
        min_length=10,
        description="Google reCAPTCHA v3 token (action=admin_login)",
    )


class TokenPair(BaseModel):
    """Auth oqimlari natijasi: tokenlar + foydalanuvchi."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_at: datetime
    user: UserMe


class RefreshRequest(BaseModel):
    refresh_token: str


class LogoutRequest(BaseModel):
    refresh_token: str
