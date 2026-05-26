"""External map reviews — Google Maps, Yandex Maps, 2GIS integratsiyasi.

Arxitektura:
    BaseReviewProvider (abstract)
       ├── GooglePlacesProvider     (Places API v1)
       ├── YandexPlacesProvider     (Search API v3 + Places)
       └── GisProvider              (Catalog API v3)

`ReviewAggregator` — har post uchun 3 ta provider'dan reviewlarni
yig'adi, DB ga cache qiladi va aggregated response qaytaradi.
"""

from app.services.external_reviews.aggregator import ReviewAggregator
from app.services.external_reviews.base import (
    BaseReviewProvider,
    FetchedReview,
    ProviderResult,
)
from app.services.external_reviews.gis import GisProvider
from app.services.external_reviews.google import GooglePlacesProvider
from app.services.external_reviews.yandex import YandexPlacesProvider

__all__ = [
    "BaseReviewProvider",
    "FetchedReview",
    "GisProvider",
    "GooglePlacesProvider",
    "ProviderResult",
    "ReviewAggregator",
    "YandexPlacesProvider",
]
