"""User Pydantic schema'lari."""

from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.models.user import UserRole


class UserPublic(BaseModel):
    """Boshqa foydalanuvchilar ko'radigan public profile."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    fullname: str
    img_url: str | None = None


class UserMe(UserPublic):
    """Foydalanuvchining o'z profili (sezgir maydonlar bilan)."""

    phone: str | None = None
    email: EmailStr | None = None
    role: str
    language: str
    created_at: datetime
    last_login_at: datetime | None = None


class UserAdmin(UserMe):
    """Admin ko'radigan to'liq profile."""

    google_sub: str | None = None
    telegram_id: int | None = None
    is_banned: bool
    device_type: str | None = None
    updated_at: datetime


class UserUpdate(BaseModel):
    """Foydalanuvchi o'z profilini yangilashi (PATCH /users/me)."""

    fullname: str | None = Field(default=None, min_length=1, max_length=100)
    email: EmailStr | None = None
    language: str | None = Field(default=None, pattern=r"^(uz|ru|en)$")


class UserAdminUpdate(BaseModel):
    """Admin foydalanuvchi rolini / banni o'zgartirish."""

    role: UserRole | None = None
    is_banned: bool | None = None
