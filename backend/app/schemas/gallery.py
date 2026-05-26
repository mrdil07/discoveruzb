"""Gallery Pydantic schema'lari."""

from __future__ import annotations

from datetime import date as DateType, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class GalleryCreate(BaseModel):
    place_name: str = Field(min_length=1, max_length=200)
    images: list[str] = []
    date: DateType | None = None
    is_public: bool = False


class GalleryUpdate(BaseModel):
    place_name: str | None = Field(default=None, min_length=1, max_length=200)
    date: DateType | None = None
    is_public: bool | None = None


class GalleryAddImages(BaseModel):
    images: list[str] = Field(min_length=1)


class GalleryRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_id: UUID
    place_name: str
    images: list[str]
    date: DateType | None = None
    is_public: bool
    share_slug: str | None = None
    created_at: datetime
    updated_at: datetime


class GalleryShareLink(BaseModel):
    slug: str
    url: str
