"""Tashqi reviewlarni yig'ish va DB cache.

Oqim:
    1. `get_or_fetch(post)` chaqirilsa, har source uchun:
       a. `PlaceFetchLog.last_fetched_at` `cache_hours` ichida bo'lsa →
          DB'dagi cached reviewlarni qaytarish.
       b. Yo'q bo'lsa → provider'dan fetch, DB'ga upsert, log yangilash.
    2. `force_refresh(post, sources)` — cache'ni ignore qilib qayta yig'ish.
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Iterable
from uuid import UUID

import asyncio

from sqlalchemy import select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.logging import get_logger
from app.models.external_review import (
    ExternalReview,
    PlaceFetchLog,
    ReviewSource,
)
from app.models.post import Post
from app.services.external_reviews.base import (
    BaseReviewProvider,
    FetchedReview,
    ProviderResult,
)
from app.services.external_reviews.gis import GisProvider
from app.services.external_reviews.google import GooglePlacesProvider
from app.services.external_reviews.yandex import YandexPlacesProvider

logger = get_logger(__name__)


class ReviewAggregator:
    """Multi-provider review aggregator.

    Mas'uliyatlari:
    - Cache muddatini hisobga olish (`external_reviews_cache_hours`).
    - 3 ta provider'dan parallel fetch (`asyncio.gather`).
    - Reviewlarni DB'ga idempotent upsert.
    - `PlaceFetchLog` ga summary yozish.
    """

    def __init__(
        self,
        providers: Iterable[BaseReviewProvider] | None = None,
    ) -> None:
        self._providers: dict[str, BaseReviewProvider] = {
            p.SOURCE: p
            for p in (providers or [
                GooglePlacesProvider(),
                YandexPlacesProvider(),
                GisProvider(),
            ])
        }

    # =====================================================
    # Public API
    # =====================================================

    async def get_or_fetch(
        self,
        db: AsyncSession,
        post: Post,
        *,
        force: bool = False,
        sources: Iterable[ReviewSource] | None = None,
    ) -> dict[str, ProviderResult]:
        """Har source uchun ProviderResult qaytaradi.

        Cache hit bo'lsa, DB'dagi reviewlardan `FetchedReview` yaratiladi.
        """
        wanted = self._normalize_sources(sources)
        results: dict[str, ProviderResult] = {}

        # Cache mavjudligini tekshirish
        cache_cutoff = datetime.now(UTC) - timedelta(
            hours=settings.external_reviews_cache_hours
        )
        logs = {
            log.source: log
            for log in (
                await db.scalars(
                    select(PlaceFetchLog).where(PlaceFetchLog.post_id == post.id)
                )
            ).all()
        }

        # Har source uchun: cache vs fetch
        fetch_tasks: list[tuple[str, str]] = []  # (source, place_id)
        for source in wanted:
            place_id = self._place_id_for(post, source)
            if not place_id:
                results[source] = ProviderResult(
                    source=source, error="place_id sozlanmagan"
                )
                continue

            log = logs.get(source)
            if not force and log and log.last_fetched_at > cache_cutoff:
                # Cache hit — DB'dan
                results[source] = await self._load_cached(db, post.id, source, log)
            else:
                fetch_tasks.append((source, place_id))

        # Parallel HTTP fetch (provider chaqiriqlari I/O-bound, mustaqil)
        if fetch_tasks:
            provider_results = await asyncio.gather(
                *[
                    self._fetch_only(source, place_id)
                    for source, place_id in fetch_tasks
                ],
                return_exceptions=False,
            )
            # DB yozish — serial (asyncpg bir session'da parallel ops bermaydi)
            for (source, _), result in zip(fetch_tasks, provider_results):
                if result.ok and result.reviews:
                    await self._upsert_reviews(db, post.id, source, result.reviews)
                await self._upsert_log(db, post.id, source, result)
                results[source] = result
            await db.commit()

        return results

    # =====================================================
    # Helpers
    # =====================================================

    @staticmethod
    def _normalize_sources(
        sources: Iterable[ReviewSource] | None,
    ) -> list[str]:
        if sources is None:
            return [s.value for s in ReviewSource]
        return [s.value if isinstance(s, ReviewSource) else s for s in sources]

    @staticmethod
    def _place_id_for(post: Post, source: str) -> str | None:
        if source == ReviewSource.GOOGLE.value:
            return post.google_place_id
        if source == ReviewSource.YANDEX.value:
            return post.yandex_place_id
        if source == ReviewSource.GIS.value:
            return post.gis_place_id
        return None

    async def _load_cached(
        self,
        db: AsyncSession,
        post_id: UUID,
        source: str,
        log: PlaceFetchLog,
    ) -> ProviderResult:
        rows = (
            await db.scalars(
                select(ExternalReview)
                .where(
                    ExternalReview.post_id == post_id,
                    ExternalReview.source == source,
                )
                .order_by(ExternalReview.posted_at.desc().nulls_last())
            )
        ).all()
        reviews = [
            FetchedReview(
                external_id=r.external_id,
                author_name=r.author_name,
                author_avatar_url=r.author_avatar_url,
                author_profile_url=r.author_profile_url,
                rating=r.rating,
                text=r.text,
                posted_at=r.posted_at,
                language=r.language,
                helpful_count=r.helpful_count,
            )
            for r in rows
        ]
        return ProviderResult(
            source=source,
            reviews=reviews,
            average_rating=log.average_rating,
            total_count=log.review_count,
            error=log.error,
        )

    async def _fetch_only(
        self,
        source: str,
        place_id: str,
    ) -> ProviderResult:
        """Provider'dan fetch — DB yozmaydi (parallel ishlatish uchun xavfsiz)."""
        provider = self._providers.get(source)
        if provider is None:
            return ProviderResult(source=source, error="Provider topilmadi")

        return await provider.fetch_reviews(
            place_id,
            limit=settings.external_reviews_per_source_limit,
        )

    async def _upsert_reviews(
        self,
        db: AsyncSession,
        post_id: UUID,
        source: str,
        reviews: list[FetchedReview],
    ) -> None:
        now = datetime.now(UTC)
        values = [
            {
                "post_id": post_id,
                "source": source,
                "external_id": r.external_id,
                "author_name": r.author_name,
                "author_avatar_url": r.author_avatar_url,
                "author_profile_url": r.author_profile_url,
                "rating": r.rating,
                "text": r.text,
                "language": r.language,
                "posted_at": r.posted_at,
                "fetched_at": now,
                "helpful_count": r.helpful_count,
            }
            for r in reviews
            if r.external_id  # bo'sh external_id'lar — skip
        ]
        if not values:
            return

        stmt = insert(ExternalReview).values(values)
        # `(post_id, source, external_id)` — uniq — update on conflict
        stmt = stmt.on_conflict_do_update(
            constraint="uq_external_reviews_post_source_external",
            set_={
                "author_name": stmt.excluded.author_name,
                "author_avatar_url": stmt.excluded.author_avatar_url,
                "author_profile_url": stmt.excluded.author_profile_url,
                "rating": stmt.excluded.rating,
                "text": stmt.excluded.text,
                "language": stmt.excluded.language,
                "posted_at": stmt.excluded.posted_at,
                "fetched_at": stmt.excluded.fetched_at,
                "helpful_count": stmt.excluded.helpful_count,
            },
        )
        await db.execute(stmt)

    async def _upsert_log(
        self,
        db: AsyncSession,
        post_id: UUID,
        source: str,
        result: ProviderResult,
    ) -> None:
        values = {
            "post_id": post_id,
            "source": source,
            "last_fetched_at": datetime.now(UTC),
            "review_count": result.total_count or len(result.reviews),
            "average_rating": result.average_rating,
            "error": result.error,
        }
        stmt = insert(PlaceFetchLog).values(**values)
        stmt = stmt.on_conflict_do_update(
            constraint="uq_place_fetch_logs_post_source",
            set_={
                "last_fetched_at": stmt.excluded.last_fetched_at,
                "review_count": stmt.excluded.review_count,
                "average_rating": stmt.excluded.average_rating,
                "error": stmt.excluded.error,
            },
        )
        await db.execute(stmt)


_singleton: ReviewAggregator | None = None


def get_aggregator() -> ReviewAggregator:
    """FastAPI dependency factory."""
    global _singleton
    if _singleton is None:
        _singleton = ReviewAggregator()
    return _singleton
