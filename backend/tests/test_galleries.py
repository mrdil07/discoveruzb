"""Galleries router testlari."""

from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.gallery import Gallery
from tests.conftest import auth_headers


async def _create_gallery(db: AsyncSession, owner_id, **overrides) -> Gallery:
    payload = {
        "owner_id": owner_id,
        "place_name": "Test galereya",
        "images": ["https://media.test/g/1.webp"],
    }
    payload.update(overrides)
    gallery = Gallery(**payload)
    db.add(gallery)
    await db.commit()
    await db.refresh(gallery)
    return gallery


@pytest.mark.asyncio
async def test_create_gallery(client: AsyncClient, normal_user):
    response = await client.post(
        "/api/v1/galleries",
        headers=auth_headers(normal_user),
        json={
            "place_name": "Yangi galereya",
            "images": ["https://media.test/g/a.webp"],
            "is_public": False,
        },
    )
    assert response.status_code == 201, response.text
    body = response.json()
    assert body["place_name"] == "Yangi galereya"
    assert body["owner_id"] == str(normal_user.id)


@pytest.mark.asyncio
async def test_list_my_galleries(
    client: AsyncClient, db_session: AsyncSession, normal_user
):
    await _create_gallery(db_session, normal_user.id, place_name="A")
    await _create_gallery(db_session, normal_user.id, place_name="B")

    response = await client.get(
        "/api/v1/galleries/me", headers=auth_headers(normal_user)
    )
    assert response.status_code == 200
    assert len(response.json()) == 2


@pytest.mark.asyncio
async def test_add_images(
    client: AsyncClient, db_session: AsyncSession, normal_user
):
    gallery = await _create_gallery(db_session, normal_user.id)
    response = await client.post(
        f"/api/v1/galleries/{gallery.id}/images",
        headers=auth_headers(normal_user),
        json={"images": ["https://media.test/g/2.webp"]},
    )
    assert response.status_code == 200
    assert len(response.json()["images"]) == 2


@pytest.mark.asyncio
async def test_share_link_creates_slug(
    client: AsyncClient, db_session: AsyncSession, normal_user
):
    gallery = await _create_gallery(db_session, normal_user.id)
    response = await client.post(
        f"/api/v1/galleries/{gallery.id}/share-link",
        headers=auth_headers(normal_user),
    )
    assert response.status_code == 200
    body = response.json()
    assert body["slug"]
    assert body["url"]


@pytest.mark.asyncio
async def test_public_share_view(
    client: AsyncClient, db_session: AsyncSession, normal_user
):
    gallery = await _create_gallery(
        db_session,
        normal_user.id,
        is_public=True,
        share_slug="test-slug-123",
    )
    # Public — auth talab qilinmaydi
    response = await client.get(f"/api/v1/galleries/share/{gallery.share_slug}")
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_cannot_update_others_gallery(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    moderator_user,
):
    gallery = await _create_gallery(db_session, moderator_user.id)
    response = await client.patch(
        f"/api/v1/galleries/{gallery.id}",
        headers=auth_headers(normal_user),
        json={"place_name": "Hack"},
    )
    assert response.status_code == 403
