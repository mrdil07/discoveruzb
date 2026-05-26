"""2GIS Catalog API integratsiyasi.

API hujjati: https://docs.2gis.com/ru/api/search/places/overview

Endpoint: `GET https://catalog.api.2gis.com/3.0/items/byid?id={place_id}&key={key}`
Reviews uchun alohida endpoint: `https://public-api.reviews.2gis.com/2.0/branches/{id}/reviews?...`

2GIS B2B API rasmiy `key` orqali ishlatiladi. Public reviews endpoint
ham `key` talab qiladi (rate-limit bilan).
"""

from __future__ import annotations

from datetime import datetime
from typing import Any, ClassVar

import httpx

from app.core.config import settings
from app.core.logging import get_logger
from app.services.external_reviews.base import (
    BaseReviewProvider,
    FetchedReview,
    ProviderResult,
)

logger = get_logger(__name__)


class GisProvider(BaseReviewProvider):
    SOURCE: ClassVar[str] = "2gis"
    REVIEWS_URL: ClassVar[str] = (
        "https://public-api.reviews.2gis.com/2.0/branches/{place_id}/reviews"
    )

    def is_configured(self) -> bool:
        return bool(settings.gis_api_key)

    async def fetch_reviews(
        self,
        place_id: str,
        *,
        limit: int = 20,
        language: str = "uz",
    ) -> ProviderResult:
        if not self.is_configured():
            return ProviderResult(source=self.SOURCE, error="GIS_API_KEY sozlanmagan")

        url = self.REVIEWS_URL.format(place_id=place_id)
        params = {
            "key": settings.gis_api_key,
            "limit": min(limit, 50),
            "fields": "meta.org_rating,meta.org_reviews_count",
            "sort_by": "date_edited",
            "locale": _gis_locale(language),
        }
        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                response = await client.get(url, params=params)
        except httpx.HTTPError as e:
            logger.warning("2GIS network error: %s", e)
            return ProviderResult(source=self.SOURCE, error=f"network: {e}")

        if response.status_code != 200:
            logger.warning(
                "2GIS %s for place=%s: %s",
                response.status_code, place_id, response.text[:200],
            )
            return ProviderResult(
                source=self.SOURCE,
                error=f"HTTP {response.status_code}",
            )

        return _parse_gis(response.json())


def _gis_locale(lang: str) -> str:
    """2GIS locale kodlari: ru_RU, en_US, uz_UZ."""
    mapping = {"uz": "uz_UZ", "ru": "ru_RU", "en": "en_US"}
    return mapping.get(lang, "ru_RU")


def _parse_gis(data: dict[str, Any]) -> ProviderResult:
    """2GIS reviews API javobini parse qiladi.

    Schema: `{ "reviews": [...], "meta": { "org_rating": 4.5, "org_reviews_count": 100 } }`
    """
    meta = data.get("meta", {}) or {}
    raw_reviews = data.get("reviews", []) or []

    reviews: list[FetchedReview] = []
    for r in raw_reviews:
        user = r.get("user", {}) or {}
        reviews.append(
            FetchedReview(
                external_id=str(r.get("id", "")),
                author_name=user.get("name", "2GIS User"),
                author_avatar_url=user.get("avatar"),
                rating=float(r.get("rating", 0)) if r.get("rating") else None,
                text=r.get("text"),
                posted_at=_parse_gis_date(r.get("date_created")),
                helpful_count=int(r.get("likes_count", 0) or 0),
                language=r.get("language"),
            )
        )

    return ProviderResult(
        source="2gis",
        reviews=reviews,
        average_rating=meta.get("org_rating"),
        total_count=int(meta.get("org_reviews_count", 0) or 0),
    )


def _parse_gis_date(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except (ValueError, TypeError):
        return None
