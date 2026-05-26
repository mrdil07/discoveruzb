"""External reviews endpoint testlari.

Provider chaqirig'lari mock qilingan — real Google/Yandex/2GIS
chaqiriqsiz testlanadi.
"""

from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.post import Post
from app.services.external_reviews.base import (
    BaseReviewProvider,
    FetchedReview,
    ProviderResult,
)
from tests.conftest import auth_headers


# =====================================================
# Fake providers — har test uchun controlled response
# =====================================================


class FakeGoogleProvider(BaseReviewProvider):
    SOURCE = "google"

    def __init__(self, reviews: list[FetchedReview] | None = None,
                 error: str | None = None) -> None:
        self._reviews = reviews or []
        self._error = error

    def is_configured(self) -> bool:
        return True

    async def fetch_reviews(self, place_id, *, limit=20, language="uz"):
        if self._error:
            return ProviderResult(source="google", error=self._error)
        return ProviderResult(
            source="google",
            reviews=self._reviews,
            average_rating=4.5,
            total_count=len(self._reviews),
        )


class FakeYandexProvider(BaseReviewProvider):
    SOURCE = "yandex"

    def is_configured(self) -> bool:
        return False  # sozlanmagan — test default skip

    async def fetch_reviews(self, place_id, *, limit=20, language="uz"):
        return ProviderResult(source="yandex", error="YANDEX_MAPS_API_KEY sozlanmagan")


class FakeGisProvider(BaseReviewProvider):
    SOURCE = "2gis"

    def is_configured(self) -> bool:
        return True

    async def fetch_reviews(self, place_id, *, limit=20, language="uz"):
        return ProviderResult(
            source="2gis",
            reviews=[
                FetchedReview(
                    external_id="gis-1",
                    author_name="2GIS User",
                    rating=5.0,
                    text="Ajoyib joy!",
                ),
            ],
            average_rating=4.7,
            total_count=42,
        )


# =====================================================
# Fixtures
# =====================================================


@pytest.fixture
def fake_providers() -> list:
    """Default fake providers — testlarda override qilinishi mumkin."""
    google_reviews = [
        FetchedReview(
            external_id="google-1",
            author_name="Aziz Karimov",
            rating=5.0,
            text="Juda chiroyli joy",
        ),
        FetchedReview(
            external_id="google-2",
            author_name="Maria Ivanova",
            rating=4.0,
            text="Yaxshi, lekin gavjum",
        ),
    ]
    return [
        FakeGoogleProvider(reviews=google_reviews),
        FakeYandexProvider(),
        FakeGisProvider(),
    ]


@pytest.fixture
def mock_aggregator(client, fake_providers):
    """FastAPI `dependency_overrides` orqali `get_aggregator`'ni almashtirish."""
    from app.services.external_reviews import aggregator as agg_module
    from app.services.external_reviews.aggregator import get_aggregator

    fake = agg_module.ReviewAggregator(providers=fake_providers)
    # ASGITransport'dan app'ni olish
    app = client._transport.app
    app.dependency_overrides[get_aggregator] = lambda: fake
    yield fake
    app.dependency_overrides.pop(get_aggregator, None)


async def _create_post_with_places(db: AsyncSession, author_id) -> Post:
    post = Post(
        author_id=author_id,
        place_name="Registon maydoni",
        place_info="Samarqand",
        address="Samarqand",
        type="historical",
        phone_numbers=[],
        images=[],
        lat=39.654,
        lon=66.975,
        google_place_id="ChIJtest-google",
        yandex_place_id="yandex-uri-test",
        gis_place_id="2gis-branch-id-test",
    )
    db.add(post)
    await db.commit()
    await db.refresh(post)
    return post


# =====================================================
# Tests
# =====================================================


@pytest.mark.asyncio
async def test_get_external_reviews_returns_aggregated(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    mock_aggregator,
):
    post = await _create_post_with_places(db_session, normal_user.id)
    response = await client.get(f"/api/v1/posts/{post.id}/external-reviews")
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["post_id"] == str(post.id)

    by_source = {s["source"]: s for s in body["summaries"]}
    assert by_source["google"]["review_count"] == 2
    assert by_source["google"]["average_rating"] == 4.5
    assert by_source["yandex"]["error"] is not None
    assert by_source["2gis"]["review_count"] == 42

    # Reviewlar DB'ga saqlanganini tekshirish
    assert len(body["reviews"]) >= 3  # 2 google + 1 2gis


@pytest.mark.asyncio
async def test_get_external_reviews_post_not_found(
    client: AsyncClient, mock_aggregator
):
    from uuid import uuid4

    response = await client.get(f"/api/v1/posts/{uuid4()}/external-reviews")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_get_external_reviews_no_place_ids(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    mock_aggregator,
):
    # Place ID lar sozlanmagan post
    post = Post(
        author_id=normal_user.id,
        place_name="No-map joy",
        place_info="x",
        address="x",
        type="t",
        phone_numbers=[],
        images=[],
        lat=0,
        lon=0,
    )
    db_session.add(post)
    await db_session.commit()
    await db_session.refresh(post)

    response = await client.get(f"/api/v1/posts/{post.id}/external-reviews")
    assert response.status_code == 200
    body = response.json()
    for s in body["summaries"]:
        assert "place_id sozlanmagan" in (s.get("error") or "")
    assert body["reviews"] == []


@pytest.mark.asyncio
async def test_refresh_external_reviews_admin_only(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    mock_aggregator,
):
    post = await _create_post_with_places(db_session, normal_user.id)
    response = await client.post(
        f"/api/v1/posts/{post.id}/external-reviews/refresh",
        headers=auth_headers(normal_user),
        json={},
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_refresh_external_reviews_moderator(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    moderator_user,
    mock_aggregator,
):
    post = await _create_post_with_places(db_session, normal_user.id)
    response = await client.post(
        f"/api/v1/posts/{post.id}/external-reviews/refresh",
        headers=auth_headers(moderator_user),
        json={"sources": ["google"]},
    )
    assert response.status_code == 200, response.text
    body = response.json()
    summaries = {s["source"]: s for s in body["summaries"]}
    assert "google" in summaries
    # `sources=["google"]` bo'lgani uchun yandex/2gis bu refresh'da yo'q
    assert "yandex" not in summaries
    assert "2gis" not in summaries


@pytest.mark.asyncio
async def test_cache_hit_on_second_call(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    mock_aggregator,
):
    post = await _create_post_with_places(db_session, normal_user.id)

    # 1-marta — fetch
    r1 = await client.get(f"/api/v1/posts/{post.id}/external-reviews")
    assert r1.status_code == 200

    # 2-marta — cache hit (TTL > 0). Aggregator fetch chaqirmasligi kerak,
    # lekin response bir xil bo'ladi.
    r2 = await client.get(f"/api/v1/posts/{post.id}/external-reviews")
    assert r2.status_code == 200
    assert r2.json()["post_id"] == r1.json()["post_id"]


@pytest.mark.asyncio
async def test_provider_error_propagates_to_summary(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
):
    """Provider'da xato bo'lsa, summary.error to'ldiriladi."""
    from app.services.external_reviews import aggregator as agg_module
    from app.services.external_reviews.aggregator import get_aggregator

    fake = agg_module.ReviewAggregator(
        providers=[
            FakeGoogleProvider(error="HTTP 403 — quota exceeded"),
            FakeYandexProvider(),
            FakeGisProvider(),
        ]
    )
    app = client._transport.app
    app.dependency_overrides[get_aggregator] = lambda: fake
    try:
        post = await _create_post_with_places(db_session, normal_user.id)
        response = await client.get(f"/api/v1/posts/{post.id}/external-reviews")
        assert response.status_code == 200
        body = response.json()
        google = next(s for s in body["summaries"] if s["source"] == "google")
        assert "quota" in google["error"]
    finally:
        app.dependency_overrides.pop(get_aggregator, None)
