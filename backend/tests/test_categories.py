"""Categories router testlari."""

from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.category import Category
from tests.conftest import auth_headers


def _payload(slug="historical", **overrides):
    base = {
        "slug": slug,
        "name_uz": "Tarixiy",
        "name_ru": "Исторический",
        "name_en": "Historical",
        "icon_url": None,
        "sort_order": 0,
        "is_active": True,
    }
    base.update(overrides)
    return base


@pytest.mark.asyncio
async def test_list_categories_public(
    client: AsyncClient, db_session: AsyncSession
):
    db_session.add_all([
        Category(**_payload(slug="historical")),
        Category(**_payload(slug="mountain", name_uz="Tog'lar")),
    ])
    await db_session.commit()

    response = await client.get("/api/v1/categories")
    assert response.status_code == 200
    items = response.json()
    assert len(items) == 2


@pytest.mark.asyncio
async def test_only_active_filter(
    client: AsyncClient, db_session: AsyncSession
):
    db_session.add_all([
        Category(**_payload(slug="active1", is_active=True)),
        Category(**_payload(slug="inactive1", is_active=False)),
    ])
    await db_session.commit()

    r_active = await client.get("/api/v1/categories")
    r_all = await client.get(
        "/api/v1/categories", params={"only_active": "false"}
    )
    assert len(r_active.json()) == 1
    assert len(r_all.json()) == 2


@pytest.mark.asyncio
async def test_admin_create_category(client: AsyncClient, admin_user):
    response = await client.post(
        "/api/v1/categories",
        headers=auth_headers(admin_user),
        json=_payload(slug="new"),
    )
    assert response.status_code == 201
    assert response.json()["slug"] == "new"


@pytest.mark.asyncio
async def test_user_cannot_create(client: AsyncClient, normal_user):
    response = await client.post(
        "/api/v1/categories",
        headers=auth_headers(normal_user),
        json=_payload(),
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_create_duplicate_slug(
    client: AsyncClient, db_session: AsyncSession, admin_user
):
    db_session.add(Category(**_payload(slug="dup")))
    await db_session.commit()

    response = await client.post(
        "/api/v1/categories",
        headers=auth_headers(admin_user),
        json=_payload(slug="dup"),
    )
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_admin_update_category(
    client: AsyncClient, db_session: AsyncSession, admin_user
):
    db_session.add(Category(**_payload(slug="xupdate", name_uz="Eski")))
    await db_session.commit()

    response = await client.patch(
        "/api/v1/categories/xupdate",
        headers=auth_headers(admin_user),
        json={"name_uz": "Yangi"},
    )
    assert response.status_code == 200
    assert response.json()["name_uz"] == "Yangi"


@pytest.mark.asyncio
async def test_admin_delete_category(
    client: AsyncClient, db_session: AsyncSession, admin_user
):
    db_session.add(Category(**_payload(slug="todelete")))
    await db_session.commit()

    response = await client.delete(
        "/api/v1/categories/todelete", headers=auth_headers(admin_user)
    )
    assert response.status_code == 200
