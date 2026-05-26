"""External review Pydantic schemas."""

from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.models.external_review import ReviewSource


class ExternalReviewRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    post_id: UUID
    source: str  # google | yandex | 2gis
    external_id: str
    author_name: str
    author_avatar_url: str | None = None
    author_profile_url: str | None = None
    rating: float | None = None
    text: str | None = None
    language: str | None = None
    posted_at: datetime | None = None
    helpful_count: int = 0
    fetched_at: datetime


class SourceSummary(BaseModel):
    """Bitta source bo'yicha qisqacha statistika."""
    source: str
    review_count: int
    average_rating: float | None = None
    last_fetched_at: datetime | None = None
    error: str | None = None


class ExternalReviewsResponse(BaseModel):
    """`GET /posts/{id}/external-reviews` javobi.

    Agregirlangan: har source bo'yicha summary + reviewlar ro'yxati.
    """
    post_id: UUID
    summaries: list[SourceSummary]
    reviews: list[ExternalReviewRead]


class RefreshRequest(BaseModel):
    """`POST /posts/{id}/external-reviews/refresh` body.

    Bo'sh — barcha 3 source'ni yangilash.
    `sources` — faqat ko'rsatilganlar.
    """
    sources: list[ReviewSource] | None = Field(default=None)


class RefreshResult(BaseModel):
    """Refresh natijasi — har source uchun status."""
    summaries: list[SourceSummary]
