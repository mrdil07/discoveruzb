"""Comments router — `/api/v1/comments/`."""

from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.api.deps import CurrentUser, DbSession
from app.models.comment import Comment
from app.models.post import Post
from app.schemas.comment import CommentCreate, CommentRead
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/comments", tags=["comments"])


@router.get(
    "/post/{post_id}",
    response_model=list[CommentRead],
    summary="Post bo'yicha izohlar",
)
async def list_comments(post_id: UUID, db: DbSession) -> list[CommentRead]:
    query = (
        select(Comment)
        .options(selectinload(Comment.author))
        .where(Comment.post_id == post_id)
        .order_by(Comment.created_at.desc())
    )
    comments = (await db.scalars(query)).all()
    return [CommentRead.model_validate(c) for c in comments]


@router.post(
    "/post/{post_id}",
    response_model=CommentRead,
    status_code=status.HTTP_201_CREATED,
    summary="Yangi izoh qoldirish",
)
async def create_comment(
    post_id: UUID,
    payload: CommentCreate,
    current: CurrentUser,
    db: DbSession,
) -> CommentRead:
    # Post mavjudligini tekshirish
    exists = await db.scalar(select(Post.id).where(Post.id == post_id))
    if exists is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")

    comment = Comment(post_id=post_id, author_id=current.id, body=payload.body)
    db.add(comment)
    await db.commit()
    fresh = await db.scalar(
        select(Comment).options(selectinload(Comment.author)).where(Comment.id == comment.id)
    )
    return CommentRead.model_validate(fresh)


@router.delete(
    "/{comment_id}",
    response_model=MessageResponse,
    summary="Izohni o'chirish (ega yoki moderator)",
)
async def delete_comment(
    comment_id: UUID,
    current: CurrentUser,
    db: DbSession,
) -> MessageResponse:
    comment = await db.get(Comment, comment_id)
    if comment is None:
        raise HTTPException(status_code=404, detail="Izoh topilmadi")
    if comment.author_id != current.id and not current.is_moderator:
        raise HTTPException(status_code=403, detail="Bu izohni o'chirish huquqingiz yo'q")

    await db.delete(comment)
    await db.commit()
    return MessageResponse(message="Izoh o'chirildi")
