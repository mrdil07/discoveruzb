"""Users router testlari."""

from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from tests.conftest import auth_headers


class TestMyProfile:
    @pytest.mark.asyncio
    async def test_get_me(self, client: AsyncClient, normal_user):
        response = await client.get(
            "/api/v1/users/me", headers=auth_headers(normal_user)
        )
        assert response.status_code == 200
        body = response.json()
        assert body["id"] == str(normal_user.id)
        assert "phone" in body
        assert "email" in body

    @pytest.mark.asyncio
    async def test_update_me(
        self, client: AsyncClient, normal_user, db_session: AsyncSession
    ):
        response = await client.patch(
            "/api/v1/users/me",
            headers=auth_headers(normal_user),
            json={"fullname": "Yangi Ism", "language": "ru"},
        )
        assert response.status_code == 200, response.text
        body = response.json()
        assert body["fullname"] == "Yangi Ism"
        assert body["language"] == "ru"

    @pytest.mark.asyncio
    async def test_update_me_invalid_language(
        self, client: AsyncClient, normal_user
    ):
        response = await client.patch(
            "/api/v1/users/me",
            headers=auth_headers(normal_user),
            json={"language": "xx"},
        )
        assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_set_avatar(self, client: AsyncClient, normal_user):
        response = await client.post(
            "/api/v1/users/me/avatar",
            headers=auth_headers(normal_user),
            json={"img_url": "https://media.test/avatars/x.webp"},
        )
        assert response.status_code == 200
        assert response.json()["img_url"] == "https://media.test/avatars/x.webp"

    @pytest.mark.asyncio
    async def test_set_avatar_missing_field(
        self, client: AsyncClient, normal_user
    ):
        response = await client.post(
            "/api/v1/users/me/avatar",
            headers=auth_headers(normal_user),
            json={},
        )
        assert response.status_code == 400


class TestPublicProfile:
    @pytest.mark.asyncio
    async def test_get_public(self, client: AsyncClient, normal_user):
        response = await client.get(f"/api/v1/users/{normal_user.id}")
        assert response.status_code == 200
        body = response.json()
        assert body["id"] == str(normal_user.id)
        # Public profile email/phone fielda yo'q
        assert "phone" not in body
        assert "email" not in body

    @pytest.mark.asyncio
    async def test_public_not_found(self, client: AsyncClient):
        from uuid import uuid4

        response = await client.get(f"/api/v1/users/{uuid4()}")
        assert response.status_code == 404


class TestAdminUsers:
    @pytest.mark.asyncio
    async def test_list_users_admin(
        self, client: AsyncClient, admin_user, normal_user
    ):
        response = await client.get(
            "/api/v1/users", headers=auth_headers(admin_user)
        )
        assert response.status_code == 200
        body = response.json()
        assert body["total"] >= 2
        assert len(body["items"]) >= 2

    @pytest.mark.asyncio
    async def test_list_users_forbidden_for_user(
        self, client: AsyncClient, normal_user
    ):
        response = await client.get(
            "/api/v1/users", headers=auth_headers(normal_user)
        )
        assert response.status_code == 403

    @pytest.mark.asyncio
    async def test_list_users_search_q(
        self, client: AsyncClient, admin_user, normal_user
    ):
        response = await client.get(
            "/api/v1/users",
            params={"q": normal_user.fullname.split()[0]},
            headers=auth_headers(admin_user),
        )
        assert response.status_code == 200
        body = response.json()
        assert any(u["id"] == str(normal_user.id) for u in body["items"])

    @pytest.mark.asyncio
    async def test_admin_update_role(
        self, client: AsyncClient, admin_user, normal_user
    ):
        response = await client.patch(
            f"/api/v1/users/admin/{normal_user.id}",
            headers=auth_headers(admin_user),
            json={"role": "moderator"},
        )
        assert response.status_code == 200
        assert response.json()["role"] == "moderator"

    @pytest.mark.asyncio
    async def test_admin_cannot_demote_self(
        self, client: AsyncClient, admin_user
    ):
        response = await client.patch(
            f"/api/v1/users/admin/{admin_user.id}",
            headers=auth_headers(admin_user),
            json={"role": "user"},
        )
        assert response.status_code == 400

    @pytest.mark.asyncio
    async def test_admin_ban_user(
        self, client: AsyncClient, admin_user, normal_user
    ):
        response = await client.patch(
            f"/api/v1/users/admin/{normal_user.id}",
            headers=auth_headers(admin_user),
            json={"is_banned": True},
        )
        assert response.status_code == 200
        assert response.json()["is_banned"] is True

    @pytest.mark.asyncio
    async def test_admin_delete_user(
        self, client: AsyncClient, admin_user, normal_user
    ):
        response = await client.delete(
            f"/api/v1/users/admin/{normal_user.id}",
            headers=auth_headers(admin_user),
        )
        assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_admin_cannot_delete_self(
        self, client: AsyncClient, admin_user
    ):
        response = await client.delete(
            f"/api/v1/users/admin/{admin_user.id}",
            headers=auth_headers(admin_user),
        )
        assert response.status_code == 400
