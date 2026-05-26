"""External reviews router — Google + Yandex + 2GIS reviewlarni qaytaradi.

Endpointlar:
    GET  /posts/{post_id}/external-reviews
        — cache-first, agar TTL ichida bo'lsa DB'dan; aks holda fetch.
    POST /posts/{post_id}/external-reviews/refresh
        — admin/moderator. Cache'ni ignore qilib qayta yig'adi.
"""

from __future__ import annotations

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import CurrentModerator, DbSession
from app.models.external_review import ExternalReview, PlaceFetchLog
from app.models.post import Post
from app.schemas.external_review import (
    ExternalReviewRead,
    ExternalReviewsResponse,
    RefreshRequest,
    RefreshResult,
    SourceSummary,
)
from app.services.external_reviews import ReviewAggregator
from app.services.external_reviews.aggregator import get_aggregator
from app.services.external_reviews.base import ProviderResult

router = APIRouter(prefix="/posts", tags=["external-reviews"])


@router.get(
    "/{post_id}/external-reviews",
    response_model=ExternalReviewsResponse,
    summary="Post uchun tashqi xaritalardan kommentlar (Google, Yandex, 2GIS)",
)
async def get_external_reviews(
    post_id: UUID,
    db: DbSession,
    aggregator: Annotated[ReviewAggregator, Depends(get_aggregator)],
) -> ExternalReviewsResponse:
    post = await db.get(Post, post_id)
    if post is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")

    results = await aggregator.get_or_fetch(db, post)
    return await _build_response(db, post.id, results)


@router.post(
    "/{post_id}/external-reviews/refresh",
    response_model=RefreshResult,
    summary="(Moderator+) Reviewlarni cache'ni ignore qilib qayta yig'ish",
)
async def refresh_external_reviews(
    post_id: UUID,
    payload: RefreshRequest,
    _mod: CurrentModerator,
    db: DbSession,
    aggregator: Annotated[ReviewAggregator, Depends(get_aggregator)],
) -> RefreshResult:
    post = await db.get(Post, post_id)
    if post is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")

    results = await aggregator.get_or_fetch(
        db, post, force=True, sources=payload.sources
    )
    summaries = _result_summaries(results)
    return RefreshResult(summaries=summaries)


# =====================================================
# Helpers
# =====================================================


async def _build_response(
    db: AsyncSession,
    post_id: UUID,
    results: dict[str, ProviderResult],
) -> ExternalReviewsResponse:
    # DB'dagi barcha cache'langan reviewlarni o'qish (results.reviews
    # cache hit bo'lganda allaqachon DB'dan, lekin response uniform).
    rows = (
        await db.scalars(
            select(ExternalReview)
            .where(ExternalReview.post_id == post_id)
            .order_by(ExternalReview.posted_at.desc().nulls_last())
        )
    ).all()

    summaries = _result_summaries(results)
    return ExternalReviewsResponse(
        post_id=post_id,
        summaries=summaries,
        reviews=[ExternalReviewRead.model_validate(r) for r in rows],
    )


def _result_summaries(
    results: dict[str, ProviderResult],
) -> list[SourceSummary]:
    out: list[SourceSummary] = []
    for source, res in results.items():
        out.append(
            SourceSummary(
                source=source,
                review_count=res.total_count or len(res.reviews),
                average_rating=res.average_rating,
                last_fetched_at=datetime.now(),  # response time
                error=res.error,
            )
        )
    return out
