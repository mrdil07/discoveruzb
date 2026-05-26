"""Bazaviy interfeyslar va dataklasslar — barcha provider'lar uchun umumiy."""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime
from typing import ClassVar


@dataclass(slots=True, frozen=True)
class FetchedReview:
    """Provider'dan kelgan normalizatsiyalangan review.

    `external_id` har provider doirasida unique. DB'da
    `(post_id, source, external_id)` upsert qilinadi.
    """

    external_id: str
    author_name: str
    rating: float | None = None
    text: str | None = None
    posted_at: datetime | None = None
    author_avatar_url: str | None = None
    author_profile_url: str | None = None
    language: str | None = None
    helpful_count: int = 0


@dataclass(slots=True)
class ProviderResult:
    """Bitta provider chaqiruvi natijasi."""

    source: str
    reviews: list[FetchedReview] = field(default_factory=list)
    average_rating: float | None = None
    total_count: int = 0  # provider tomonidan e'lon qilingan jami soni
    error: str | None = None

    @property
    def ok(self) -> bool:
        return self.error is None


class BaseReviewProvider(ABC):
    """Har provider shu interfeysni implementatsiya qiladi."""

    SOURCE: ClassVar[str]  # "google" | "yandex" | "2gis"

    @abstractmethod
    def is_configured(self) -> bool:
        """API key sozlanganligini tekshirish (`False` bo'lsa, fetch o'tkazib yuboriladi)."""

    @abstractmethod
    async def fetch_reviews(
        self,
        place_id: str,
        *,
        limit: int = 20,
        language: str = "uz",
    ) -> ProviderResult:
        """Provider'dan reviewlarni olib kelish."""
