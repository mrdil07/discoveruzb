"""Umumiy schema'lar — pagination, error response."""

from __future__ import annotations

from typing import Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


class Page(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int = Field(ge=1)
    size: int = Field(ge=1, le=100)
    total_pages: int


class ErrorResponse(BaseModel):
    detail: str
    code: str | None = None
    fields: dict[str, str] | None = None


class MessageResponse(BaseModel):
    message: str
