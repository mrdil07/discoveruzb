"""Posts router testlari — CRUD, search, like/save toggle, my-liked/saved."""

from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.post import Post
from tests.conftest import auth_headers


def _post_payload(**overrides):
    base = {
        "place_name": "Registon maydoni",
        "place_info": "Samarqand mashhur joyi",
        "address": "Samarqand, O'zbekiston",
        "type": "historical",
        "source": "Wikipedia",
        "price": "Bepul",
        "phone_numbers": ["+998901234567"],
        "images": ["https://media.test/post.webp"],
        "lat": 39.654,
        "lon": 66.975,
    }
    base.update(overrides)
    return base


async def _create_post(db: AsyncSession, author_id, **overrides) -> Post:
    post = Post(author_id=author_id, **_post_payload(**overrides))
    db.add(post)
    await db.commit()
    await db.refresh(post)
    return post


class TestListPosts:
    @pytest.mark.asyncio
    async def test_list_empty(self, client: AsyncClient):
        response = await client.get("/api/v1/posts")
        assert response.status_code == 200
        assert response.json()["total"] == 0

    @pytest.mark.asyncio
    async def test_list_with_data(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        await _create_post(db_session, normal_user.id, place_name="Joy 1")
        await _create_post(db_session, normal_user.id, place_name="Joy 2")

        response = await client.get("/api/v1/posts")
        assert response.status_code == 200
        body = response.json()
        assert body["total"] == 2
        assert len(body["items"]) == 2

    @pytest.mark.asyncio
    async def test_filter_by_type(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        await _create_post(db_session, normal_user.id, type="historical")
        await _create_post(db_session, normal_user.id, type="mountain")

        response = await client.get("/api/v1/posts", params={"type": "mountain"})
        body = response.json()
        assert body["total"] == 1
        assert body["items"][0]["type"] == "mountain"

    @pytest.mark.asyncio
    async def test_pagination(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        for i in range(5):
            await _create_post(
                db_session, normal_user.id, place_name=f"Joy {i}"
            )

        response = await client.get("/api/v1/posts", params={"size": 2, "page": 2})
        body = response.json()
        assert body["total"] == 5
        assert len(body["items"]) == 2
        assert body["total_pages"] == 3

    @pytest.mark.asyncio
    async def test_unpublished_hidden_from_list(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        await _create_post(
            db_session, normal_user.id, place_name="Hidden"
        )
        # Mark hidden
        from sqlalchemy import update

        await db_session.execute(update(Post).values(is_published=False))
        await db_session.commit()

        response = await client.get("/api/v1/posts")
        assert response.json()["total"] == 0


class TestFamousAndSearch:
    @pytest.mark.asyncio
    async def test_famous_orders_by_likes(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        await _create_post(db_session, normal_user.id, place_name="A", like_count=5)
        await _create_post(db_session, normal_user.id, place_name="B", like_count=10)

        response = await client.get("/api/v1/posts/famous")
        assert response.status_code == 200
        items = response.json()
        assert items[0]["place_name"] == "B"

    @pytest.mark.asyncio
    async def test_search_by_name(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        await _create_post(
            db_session, normal_user.id, place_name="Registon maydoni"
        )
        await _create_post(
            db_session, normal_user.id, place_name="Chimgan tog'lari"
        )

        response = await client.get("/api/v1/posts/search", params={"q": "Regis"})
        items = response.json()
        assert len(items) == 1
        assert items[0]["place_name"] == "Registon maydoni"


class TestCRUD:
    @pytest.mark.asyncio
    async def test_create_post(self, client: AsyncClient, normal_user):
        response = await client.post(
            "/api/v1/posts",
            headers=auth_headers(normal_user),
            json=_post_payload(place_name="Yangi joy"),
        )
        assert response.status_code == 201, response.text
        body = response.json()
        assert body["place_name"] == "Yangi joy"
        assert body["author_id"] == str(normal_user.id)
        assert body["like_count"] == 0

    @pytest.mark.asyncio
    async def test_create_post_requires_auth(self, client: AsyncClient):
        response = await client.post("/api/v1/posts", json=_post_payload())
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_get_post(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        post = await _create_post(db_session, normal_user.id)
        response = await client.get(f"/api/v1/posts/{post.id}")
        assert response.status_code == 200
        assert response.json()["place_name"] == post.place_name

    @pytest.mark.asyncio
    async def test_update_post_by_owner(
        self, client: AsyncClient, db_session: AsyncSession, normal_user
    ):
        post = await _create_post(db_session, normal_user.id)
        response = await client.patch(
            f"/api/v1/posts/{post.id}",
            headers=auth_headers(normal_user),
            json={"place_name": "Yangi nom"},
        )
        assert response.status_code == 200
        assert response.json()["place_name"] == "Yangi nom"

    @pytest.mark.asyncio
    async def test_update_post_forbidden_for_others(
        self,
        client: AsyncClient,
        db_session: AsyncSession,
        normal_user,
        moderator_user,
    ):
        post = await _create_post(db_session, moderator_user.id)
        response = await client.patch(
            f"/api/v1/posts/{post.id}",
            headers=auth_headers(normal_user),
            json={"place_name": "Other can't"},
        )
        assert response.status_code == 403

    @pytest.mark.asyncio
    async def test_delete_post_by_admin(
        self,
        client: AsyncClient,
        db_session: AsyncSession,
        admin_user,
        normal_user,
    ):
        post = await _create_post(db_session, normal_user.id)
        response = await client.delete(
            f"/api/v1/posts/{post.id}",
            headers=auth_headers(admin_user),
        )
        assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_delete_post_forbidden_for_others(
        self,
        client: AsyncClient,
        db_session: AsyncSession,
        normal_user,
        moderator_user,
    ):
        post = await _create_post(db_session, moderator_user.id)
        response = await client.delete(
            f"/api/v1/posts/{post.id}",
            headers=auth_headers(normal_user),
        )
        assert response.status_code == 403


class TestLikeSaveToggle:
    @pytest.mark.asyncio
    async def test_toggle_like_on_off(
        self, client: AsyncClient, db_session: AsyncSession, normal_user, moderator_user
    ):
        post = await _create_post(db_session, moderator_user.id)
        headers = auth_headers(normal_user)

        # 1-marta — qo'shadi
        r1 = await client.post(f"/api/v1/posts/{post.id}/like", headers=headers)
        assert r1.status_code == 200
        assert r1.json()["is_liked"] is True
        assert r1.json()["like_count"] == 1

        # 2-marta — olib tashlaydi
        r2 = await client.post(f"/api/v1/posts/{post.id}/like", headers=headers)
        assert r2.status_code == 200
        assert r2.json()["is_liked"] is False
        assert r2.json()["like_count"] == 0

    @pytest.mark.asyncio
    async def test_toggle_save_on_off(
        self,
        client: AsyncClient,
        db_session: AsyncSession,
        normal_user,
        moderator_user,
    ):
        post = await _create_post(db_session, moderator_user.id)
        headers = auth_headers(normal_user)

        r1 = await client.post(f"/api/v1/posts/{post.id}/save", headers=headers)
        assert r1.json()["is_saved"] is True

        r2 = await client.post(f"/api/v1/posts/{post.id}/save", headers=headers)
        assert r2.json()["is_saved"] is False

    @pytest.mark.asyncio
    async def test_my_liked(
        self,
        client: AsyncClient,
        db_session: AsyncSession,
        normal_user,
        moderator_user,
    ):
        post = await _create_post(db_session, moderator_user.id)
        headers = auth_headers(normal_user)

        await client.post(f"/api/v1/posts/{post.id}/like", headers=headers)
        response = await client.get("/api/v1/posts/me/liked", headers=headers)
        items = response.json()
        assert len(items) == 1
        assert items[0]["id"] == str(post.id)
