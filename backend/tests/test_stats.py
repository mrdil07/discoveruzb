"""Stats router testlari (admin dashboard)."""

from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.post import Post
from tests.conftest import auth_headers


@pytest.mark.asyncio
async def test_dashboard_returns_counts(
    client: AsyncClient,
    db_session: AsyncSession,
    admin_user,
    normal_user,
):
    post = Post(
        author_id=normal_user.id,
        place_name="P1",
        place_info="",
        address="A",
        type="t",
        phone_numbers=[],
        images=[],
        lat=0,
        lon=0,
        like_count=7,
    )
    db_session.add(post)
    await db_session.commit()

    response = await client.get(
        "/api/v1/stats/dashboard", headers=auth_headers(admin_user)
    )
    assert response.status_code == 200, response.text
    body = response.json()
    assert body["total_users"] >= 2
    assert body["total_posts"] >= 1
    assert body["top_post_likes"] >= 7


@pytest.mark.asyncio
async def test_dashboard_forbidden_for_user(
    client: AsyncClient, normal_user
):
    response = await client.get(
        "/api/v1/stats/dashboard", headers=auth_headers(normal_user)
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_posts_by_type(
    client: AsyncClient,
    db_session: AsyncSession,
    admin_user,
    normal_user,
):
    base = {
        "author_id": normal_user.id,
        "place_name": "x",
        "place_info": "",
        "address": "",
        "phone_numbers": [],
        "images": [],
        "lat": 0,
        "lon": 0,
    }
    db_session.add_all([
        Post(**{**base, "type": "historical"}),
        Post(**{**base, "type": "historical"}),
        Post(**{**base, "type": "mountain"}),
    ])
    await db_session.commit()

    response = await client.get(
        "/api/v1/stats/posts-by-type", headers=auth_headers(admin_user)
    )
    items = response.json()
    by_type = {it["type"]: it["count"] for it in items}
    assert by_type["historical"] == 2
    assert by_type["mountain"] == 1


@pytest.mark.asyncio
async def test_users_by_day(client: AsyncClient, admin_user):
    response = await client.get(
        "/api/v1/stats/users-by-day",
        params={"days": 7},
        headers=auth_headers(admin_user),
    )
    assert response.status_code == 200
    assert isinstance(response.json(), list)
