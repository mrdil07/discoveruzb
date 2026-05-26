"""Yandex Maps Places API integratsiyasi.

⚠️ **Diqqat:** Yandex Maps Search API public reviewlarni qaytarmaydi
(rasmiy `places-api`'da). Reviewlarga `Yandex Maps for Business` API
yoki Yandex Maps Open Data orqali kirish mumkin (limit + ToS bilan).

Bu provider quyidagi 2 yondashuvni qo'llab-quvvatlaydi:

1. **Rasmiy API** (`yandex_maps_api_key` sozlangan bo'lsa):
   `Search API v3`'dan place details + average rating. Reviewlar
   qisman (1-3 ta featured) yoki yo'q.

2. **Stub** (`is_configured() = False`): bo'sh natija qaytaradi.

Real reviewlar uchun kelajakda Yandex.Maps SDK + WebView, yoki uchinchi
tomon scraping xizmatiga o'tish kerak (ToS hisobiga olinadi).
"""

from __future__ import annotations

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


class YandexPlacesProvider(BaseReviewProvider):
    SOURCE: ClassVar[str] = "yandex"
    SEARCH_URL: ClassVar[str] = "https://search-maps.yandex.ru/v1/"

    def is_configured(self) -> bool:
        return bool(settings.yandex_maps_api_key)

    async def fetch_reviews(
        self,
        place_id: str,
        *,
        limit: int = 20,
        language: str = "uz",
    ) -> ProviderResult:
        if not self.is_configured():
            return ProviderResult(source=self.SOURCE, error="YANDEX_MAPS_API_KEY sozlanmagan")

        # Yandex `place_id` formati: `<uri>` yoki org_id raqami.
        # Hujjat: https://yandex.ru/dev/maps/geosearch/doc/
        params = {
            "apikey": settings.yandex_maps_api_key,
            "uri": place_id,
            "lang": _yandex_lang(language),
            "results": min(limit, 10),
        }
        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                response = await client.get(self.SEARCH_URL, params=params)
        except httpx.HTTPError as e:
            logger.warning("Yandex Maps network error: %s", e)
            return ProviderResult(source=self.SOURCE, error=f"network: {e}")

        if response.status_code != 200:
            logger.warning(
                "Yandex Maps %s for place=%s: %s",
                response.status_code, place_id, response.text[:200],
            )
            return ProviderResult(
                source=self.SOURCE,
                error=f"HTTP {response.status_code}",
            )

        return _parse_yandex(response.json())


def _yandex_lang(lang: str) -> str:
    """Yandex til kodlari: ru_RU, uz_UZ, en_US."""
    mapping = {"uz": "uz_UZ", "ru": "ru_RU", "en": "en_US"}
    return mapping.get(lang, "ru_RU")


def _parse_yandex(data: dict[str, Any]) -> ProviderResult:
    """Yandex Search API javobini parse qiladi.

    NOTE: `features` ichida biznes ma'lumotlari va `CompanyMetaData` bor.
    Reviewlar `CompanyMetaData.feedback` da bo'lishi mumkin (yangi versiyada).
    """
    features = data.get("features", []) or []
    if not features:
        return ProviderResult(source="yandex", error="Not found")

    first = features[0]
    props = first.get("properties", {}) or {}
    meta = props.get("CompanyMetaData", {}) or {}

    # Rating, review count
    rating = None
    total = 0
    feedback = meta.get("Feedback") or {}
    if feedback:
        rating = feedback.get("rating")
        total = int(feedback.get("count", 0) or 0)

    # Reviewlar — Yandex Search API'da odatda yo'q
    raw_reviews = feedback.get("reviews", []) or []
    reviews: list[FetchedReview] = []
    for r in raw_reviews:
        reviews.append(
            FetchedReview(
                external_id=str(r.get("id", "")),
                author_name=(r.get("author") or {}).get("name", "Yandex User"),
                rating=r.get("rating"),
                text=r.get("text"),
            )
        )

    return ProviderResult(
        source="yandex",
        reviews=reviews,
        average_rating=rating,
        total_count=total,
    )
