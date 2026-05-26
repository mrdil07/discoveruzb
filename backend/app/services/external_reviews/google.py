"""Google Places API (New) — Place Details + Reviews integratsiyasi.

API hujjati: https://developers.google.com/maps/documentation/places/web-service/place-details

Endpoint: `GET https://places.googleapis.com/v1/places/{place_id}?fields=...&languageCode=uz`
Header: `X-Goog-Api-Key: <key>`, `X-Goog-FieldMask: reviews,rating,userRatingCount`

Cheklov: 1 place uchun maksimum 5 ta review qaytadi (Google qoidasi),
pagination yo'q. ToS bo'yicha cache 30 kungacha mumkin.
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


class GooglePlacesProvider(BaseReviewProvider):
    SOURCE: ClassVar[str] = "google"
    BASE_URL: ClassVar[str] = "https://places.googleapis.com/v1/places"

    def is_configured(self) -> bool:
        return bool(settings.google_places_api_key)

    async def fetch_reviews(
        self,
        place_id: str,
        *,
        limit: int = 20,
        language: str = "uz",
    ) -> ProviderResult:
        if not self.is_configured():
            return ProviderResult(source=self.SOURCE, error="GOOGLE_PLACES_API_KEY sozlanmagan")

        url = f"{self.BASE_URL}/{place_id}"
        headers = {
            "X-Goog-Api-Key": settings.google_places_api_key,
            "X-Goog-FieldMask": (
                "reviews,rating,userRatingCount,displayName"
            ),
        }
        params = {"languageCode": language, "regionCode": "UZ"}

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                response = await client.get(url, headers=headers, params=params)
        except httpx.HTTPError as e:
            logger.warning("Google Places network error: %s", e)
            return ProviderResult(source=self.SOURCE, error=f"network: {e}")

        if response.status_code != 200:
            logger.warning(
                "Google Places %s for place_id=%s: %s",
                response.status_code, place_id, response.text[:200],
            )
            return ProviderResult(
                source=self.SOURCE,
                error=f"HTTP {response.status_code}",
            )

        data: dict[str, Any] = response.json()
        return _parse_google(data, limit=limit)


def _parse_google(data: dict[str, Any], *, limit: int) -> ProviderResult:
    """Google response → ProviderResult."""
    raw_reviews = data.get("reviews", []) or []
    reviews: list[FetchedReview] = []
    for raw in raw_reviews[:limit]:
        author = raw.get("authorAttribution", {}) or {}
        publish_time = raw.get("publishTime")
        posted_at = _parse_iso(publish_time)
        text = (raw.get("text") or {}).get("text") or (raw.get("originalText") or {}).get("text")

        reviews.append(
            FetchedReview(
                external_id=raw.get("name", "") or f"google-{author.get('displayName', '')}-{publish_time}",
                author_name=author.get("displayName", "Anonymous"),
                author_avatar_url=author.get("photoUri"),
                author_profile_url=author.get("uri"),
                rating=raw.get("rating"),
                text=text,
                posted_at=posted_at,
                language=(raw.get("text") or {}).get("languageCode"),
            )
        )

    return ProviderResult(
        source="google",
        reviews=reviews,
        average_rating=data.get("rating"),
        total_count=int(data.get("userRatingCount", 0) or 0),
    )


def _parse_iso(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        # Google: "2024-12-01T12:34:56Z" yoki "2024-12-01T12:34:56.123Z"
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except (ValueError, TypeError):
        return None
