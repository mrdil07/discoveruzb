"""Category Pydantic schema'lari."""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class CategoryBase(BaseModel):
    slug: str = Field(min_length=2, max_length=50, pattern=r"^[a-z0-9_-]+$")
    name_uz: str = Field(min_length=1, max_length=100)
    name_ru: str = Field(min_length=1, max_length=100)
    name_en: str = Field(min_length=1, max_length=100)
    icon_url: str | None = None
    sort_order: int = 0
    is_active: bool = True


class CategoryCreate(CategoryBase):
    pass


class CategoryUpdate(BaseModel):
    name_uz: str | None = Field(default=None, min_length=1, max_length=100)
    name_ru: str | None = Field(default=None, min_length=1, max_length=100)
    name_en: str | None = Field(default=None, min_length=1, max_length=100)
    icon_url: str | None = None
    sort_order: int | None = None
    is_active: bool | None = None


class CategoryRead(CategoryBase):
    model_config = ConfigDict(from_attributes=True)
