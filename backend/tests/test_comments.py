"""Comments router testlari."""

from __future__ import annotations

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.comment import Comment
from app.models.post import Post
from tests.conftest import auth_headers


async def _create_post(db: AsyncSession, author_id) -> Post:
    post = Post(
        author_id=author_id,
        place_name="Test joy",
        place_info="Tavsif",
        address="Test manzil",
        type="historical",
        phone_numbers=[],
        images=[],
        lat=41.0,
        lon=69.0,
    )
    db.add(post)
    await db.commit()
    await db.refresh(post)
    return post


@pytest.mark.asyncio
async def test_create_comment(
    client: AsyncClient, db_session: AsyncSession, normal_user
):
    post = await _create_post(db_session, normal_user.id)
    response = await client.post(
        f"/api/v1/comments/post/{post.id}",
        headers=auth_headers(normal_user),
        json={"body": "Juda yaxshi joy!"},
    )
    assert response.status_code == 201, response.text
    body = response.json()
    assert body["body"] == "Juda yaxshi joy!"
    assert body["author_id"] == str(normal_user.id)


@pytest.mark.asyncio
async def test_list_comments(
    client: AsyncClient, db_session: AsyncSession, normal_user
):
    post = await _create_post(db_session, normal_user.id)
    db_session.add_all([
        Comment(post_id=post.id, author_id=normal_user.id, body="A"),
        Comment(post_id=post.id, author_id=normal_user.id, body="B"),
    ])
    await db_session.commit()

    response = await client.get(f"/api/v1/comments/post/{post.id}")
    assert response.status_code == 200
    items = response.json()
    assert len(items) == 2


@pytest.mark.asyncio
async def test_delete_own_comment(
    client: AsyncClient, db_session: AsyncSession, normal_user
):
    post = await _create_post(db_session, normal_user.id)
    comment = Comment(post_id=post.id, author_id=normal_user.id, body="Mine")
    db_session.add(comment)
    await db_session.commit()
    await db_session.refresh(comment)

    response = await client.delete(
        f"/api/v1/comments/{comment.id}",
        headers=auth_headers(normal_user),
    )
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_cannot_delete_others_comment(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    moderator_user,
):
    post = await _create_post(db_session, moderator_user.id)
    comment = Comment(post_id=post.id, author_id=moderator_user.id, body="x")
    db_session.add(comment)
    await db_session.commit()
    await db_session.refresh(comment)

    response = await client.delete(
        f"/api/v1/comments/{comment.id}",
        headers=auth_headers(normal_user),
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_moderator_can_delete_any_comment(
    client: AsyncClient,
    db_session: AsyncSession,
    normal_user,
    moderator_user,
):
    post = await _create_post(db_session, normal_user.id)
    comment = Comment(post_id=post.id, author_id=normal_user.id, body="x")
    db_session.add(comment)
    await db_session.commit()
    await db_session.refresh(comment)

    response = await client.delete(
        f"/api/v1/comments/{comment.id}",
        headers=auth_headers(moderator_user),
    )
    assert response.status_code == 200
