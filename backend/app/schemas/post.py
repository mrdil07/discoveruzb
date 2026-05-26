"""Post Pydantic schema'lari."""

from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.user import UserPublic


class PostBase(BaseModel):
    place_name: str = Field(min_length=1, max_length=200)
    place_info: str = Field(min_length=1)
    address: str = Field(min_length=1, max_length=300)
    type: str = Field(min_length=1, max_length=50)
    source: str | None = None
    price: str | None = None
    phone_numbers: list[str] = []
    images: list[str] = []
    lat: float = Field(ge=-90, le=90)
    lon: float = Field(ge=-180, le=180)
    # Tashqi xarita place ID lari (admin tomonidan kiritiladi)
    google_place_id: str | None = Field(default=None, max_length=255)
    yandex_place_id: str | None = Field(default=None, max_length=255)
    gis_place_id: str | None = Field(default=None, max_length=255)


class PostCreate(PostBase):
    pass


class PostUpdate(BaseModel):
    place_name: str | None = Field(default=None, min_length=1, max_length=200)
    place_info: str | None = None
    address: str | None = Field(default=None, max_length=300)
    type: str | None = Field(default=None, max_length=50)
    source: str | None = None
    price: str | None = None
    phone_numbers: list[str] | None = None
    images: list[str] | None = None
    lat: float | None = Field(default=None, ge=-90, le=90)
    lon: float | None = Field(default=None, ge=-180, le=180)
    is_published: bool | None = None
    # Tashqi xarita place ID lari
    google_place_id: str | None = Field(default=None, max_length=255)
    yandex_place_id: str | None = Field(default=None, max_length=255)
    gis_place_id: str | None = Field(default=None, max_length=255)


class PostRead(PostBase):
    """Klient mobile/admin uchun chiqadigan post."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    author_id: UUID
    author: UserPublic | None = None
    like_count: int
    is_published: bool
    created_at: datetime
    updated_at: datetime

    # Joriy user uchun (`current_user_id` bilan kontekstida hisoblanadi)
    is_liked: bool = False
    is_saved: bool = False
