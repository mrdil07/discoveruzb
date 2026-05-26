"""Tashqi xaritalardan kommentlar (Google Maps, Yandex Maps, 2GIS).

Har post (`Post`) optional ravishda 3 ta tashqi map'da place ID'ga
bog'lanadi. Backend bu ID'lar orqali tegishli API'lardan reviewlarni
yig'ib, mahalliy `external_reviews` jadvaliga cache qiladi.

Cache yangilanishi — `refreshed_at` orqali. Default 24 soat (sozlanadi).
"""

from __future__ import annotations

from datetime import datetime
from enum import StrEnum
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import (
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import UUID as PgUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.post import Post


class ReviewSource(StrEnum):
    GOOGLE = "google"
    YANDEX = "yandex"
    GIS = "2gis"


class ExternalReview(UUIDPrimaryKeyMixin, Base):
    """Tashqi xaritadan kelgan bitta review.

    `(post_id, source, external_id)` — uniq (idempotent upsert).
    """

    __tablename__ = "external_reviews"
    __table_args__ = (
        UniqueConstraint(
            "post_id", "source", "external_id",
            name="uq_external_reviews_post_source_external",
        ),
    )

    post_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("posts.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    # `google` | `yandex` | `2gis`
    source: Mapped[str] = mapped_column(String(10), nullable=False, index=True)

    # Tashqi provider ichidagi review ID — har provider o'z formatida.
    external_id: Mapped[str] = mapped_column(String(255), nullable=False)

    author_name: Mapped[str] = mapped_column(String(200), nullable=False)
    author_avatar_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    author_profile_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # 1.0 – 5.0
    rating: Mapped[float | None] = mapped_column(Float, nullable=True)
    text: Mapped[str | None] = mapped_column(Text, nullable=True)
    language: Mapped[str | None] = mapped_column(String(5), nullable=True)

    # Tashqi platformada yozilgan vaqt
    posted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Cache control
    fetched_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    # Like/helpful count (provider'da bor bo'lsa)
    helpful_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    post: Mapped["Post"] = relationship("Post", back_populates="external_reviews")


class PlaceFetchLog(UUIDPrimaryKeyMixin, Base):
    """Har provider uchun oxirgi fetch holatini saqlash.

    `last_fetched_at` orqali cache TTL boshqariladi. `error` bo'lsa,
    keyingi retry vaqti hisoblanadi.
    """

    __tablename__ = "place_fetch_logs"
    __table_args__ = (
        UniqueConstraint(
            "post_id", "source",
            name="uq_place_fetch_logs_post_source",
        ),
    )

    post_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("posts.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    source: Mapped[str] = mapped_column(String(10), nullable=False)
    last_fetched_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    review_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    average_rating: Mapped[float | None] = mapped_column(Float, nullable=True)
    error: Mapped[str | None] = mapped_column(Text, nullable=True)
