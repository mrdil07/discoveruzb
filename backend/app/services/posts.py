"""Post-related biznes mantiq (like/save toggle, like_count atomic update)."""

from __future__ import annotations

from uuid import UUID

from sqlalchemy import delete, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.post import Post, PostLike, PostSave


async def is_liked(db: AsyncSession, *, user_id: UUID, post_id: UUID) -> bool:
    result = await db.scalar(
        select(PostLike.user_id).where(
            PostLike.user_id == user_id, PostLike.post_id == post_id
        )
    )
    return result is not None


async def is_saved(db: AsyncSession, *, user_id: UUID, post_id: UUID) -> bool:
    result = await db.scalar(
        select(PostSave.user_id).where(
            PostSave.user_id == user_id, PostSave.post_id == post_id
        )
    )
    return result is not None


async def toggle_like(
    db: AsyncSession,
    *,
    user_id: UUID,
    post_id: UUID,
) -> tuple[bool, int]:
    """Toggle like va yangi `like_count` qaytaradi.

    Returns: (is_now_liked, new_like_count)
    """
    existing = await db.scalar(
        select(PostLike).where(
            PostLike.user_id == user_id, PostLike.post_id == post_id
        )
    )

    if existing is None:
        # Like qo'shish
        db.add(PostLike(user_id=user_id, post_id=post_id))
        await db.execute(
            update(Post).where(Post.id == post_id).values(like_count=Post.like_count + 1)
        )
        is_now = True
    else:
        # Like olib tashlash
        await db.execute(
            delete(PostLike).where(
                PostLike.user_id == user_id, PostLike.post_id == post_id
            )
        )
        await db.execute(
            update(Post).where(Post.id == post_id).values(like_count=Post.like_count - 1)
        )
        is_now = False

    await db.commit()

    new_count = await db.scalar(select(Post.like_count).where(Post.id == post_id))
    return is_now, new_count or 0


async def toggle_save(
    db: AsyncSession,
    *,
    user_id: UUID,
    post_id: UUID,
) -> bool:
    """Toggle save. Returns: is_now_saved."""
    existing = await db.scalar(
        select(PostSave).where(
            PostSave.user_id == user_id, PostSave.post_id == post_id
        )
    )
    if existing is None:
        db.add(PostSave(user_id=user_id, post_id=post_id))
        await db.commit()
        return True
    else:
        await db.execute(
            delete(PostSave).where(
                PostSave.user_id == user_id, PostSave.post_id == post_id
            )
        )
        await db.commit()
        return False
