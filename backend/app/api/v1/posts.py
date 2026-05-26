"""Posts router — `/api/v1/posts/`."""

from __future__ import annotations

from typing import Annotated, Literal
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import desc, select
from sqlalchemy.orm import selectinload

from app.api.deps import (
    CurrentUser,
    CurrentUserOptional,
    DbSession,
)
from app.models.post import Post, PostLike, PostSave
from app.models.user import User
from app.schemas.common import MessageResponse, Page
from app.schemas.post import PostCreate, PostRead, PostUpdate
from app.services import posts as posts_service
from app.utils.pagination import PageParams, get_page_params, paginate

router = APIRouter(prefix="/posts", tags=["posts"])


# =====================================================
# Helpers
# =====================================================


async def _attach_user_flags(
    db: DbSession,
    posts: list[Post],
    current: User | None,
) -> list[PostRead]:
    """Joriy user uchun `is_liked` va `is_saved` ni hisoblaydi."""
    if current is None or not posts:
        return [PostRead.model_validate(p) for p in posts]

    post_ids = [p.id for p in posts]

    liked_ids = set(
        (await db.scalars(
            select(PostLike.post_id).where(
                PostLike.user_id == current.id, PostLike.post_id.in_(post_ids)
            )
        )).all()
    )
    saved_ids = set(
        (await db.scalars(
            select(PostSave.post_id).where(
                PostSave.user_id == current.id, PostSave.post_id.in_(post_ids)
            )
        )).all()
    )

    result = []
    for p in posts:
        item = PostRead.model_validate(p)
        item.is_liked = p.id in liked_ids
        item.is_saved = p.id in saved_ids
        result.append(item)
    return result


# =====================================================
# Public list & search
# =====================================================


@router.get(
    "",
    response_model=Page[PostRead],
    summary="Postlar ro'yxati (filterlar bilan)",
)
async def list_posts(
    db: DbSession,
    current: CurrentUserOptional,
    params: Annotated[PageParams, Depends(get_page_params)],
    type: Annotated[str | None, Query()] = None,
    address: Annotated[str | None, Query()] = None,
    sort: Annotated[Literal["time", "like_count"], Query()] = "time",
    order: Annotated[Literal["asc", "desc"], Query()] = "desc",
) -> Page[PostRead]:
    import math

    from sqlalchemy import func

    query = select(Post).options(selectinload(Post.author)).where(Post.is_published.is_(True))

    if type:
        query = query.where(Post.type == type)
    if address:
        query = query.where(Post.address.ilike(f"%{address}%"))

    sort_col = Post.created_at if sort == "time" else Post.like_count
    query = query.order_by(desc(sort_col) if order == "desc" else sort_col)

    # Total count
    total = await db.scalar(select(func.count()).select_from(query.subquery())) or 0

    # Items
    rows = list(
        (await db.scalars(query.offset(params.offset).limit(params.size))).all()
    )
    items = await _attach_user_flags(db, rows, current)

    return Page[PostRead](
        items=items,
        total=total,
        page=params.page,
        size=params.size,
        total_pages=math.ceil(total / params.size) if total else 0,
    )


@router.get(
    "/famous",
    response_model=list[PostRead],
    summary="Eng ko'p layklangan top postlar",
)
async def famous_posts(
    db: DbSession,
    current: CurrentUserOptional,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
) -> list[PostRead]:
    query = (
        select(Post)
        .options(selectinload(Post.author))
        .where(Post.is_published.is_(True))
        .order_by(desc(Post.like_count))
        .limit(limit)
    )
    posts = list((await db.scalars(query)).all())
    return await _attach_user_flags(db, posts, current)


@router.get(
    "/recommend",
    response_model=list[PostRead],
    summary="Tavsiya etilgan postlar (hozircha = famous)",
)
async def recommend_posts(
    db: DbSession,
    current: CurrentUserOptional,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
) -> list[PostRead]:
    # TODO: Sprint 5+ — collaborative filter yoki Postgres pgvector
    return await famous_posts(db=db, current=current, limit=limit)


@router.get(
    "/search",
    response_model=list[PostRead],
    summary="Joy nomi bo'yicha qidiruv (trigram)",
)
async def search_posts(
    db: DbSession,
    current: CurrentUserOptional,
    q: Annotated[str, Query(min_length=1, max_length=100)],
    limit: Annotated[int, Query(ge=1, le=50)] = 20,
) -> list[PostRead]:
    query = (
        select(Post)
        .options(selectinload(Post.author))
        .where(Post.is_published.is_(True), Post.place_name.ilike(f"%{q}%"))
        .order_by(desc(Post.like_count))
        .limit(limit)
    )
    posts = list((await db.scalars(query)).all())
    return await _attach_user_flags(db, posts, current)


# =====================================================
# My liked / saved
# =====================================================


@router.get(
    "/me/liked",
    response_model=list[PostRead],
    summary="Joriy user'ning layklari",
)
async def my_liked(
    db: DbSession,
    current: CurrentUser,
) -> list[PostRead]:
    query = (
        select(Post)
        .options(selectinload(Post.author))
        .join(PostLike, PostLike.post_id == Post.id)
        .where(PostLike.user_id == current.id)
        .order_by(desc(PostLike.created_at))
    )
    posts = list((await db.scalars(query)).all())
    return await _attach_user_flags(db, posts, current)


@router.get(
    "/me/saved",
    response_model=list[PostRead],
    summary="Joriy user'ning saqlanganlari",
)
async def my_saved(
    db: DbSession,
    current: CurrentUser,
) -> list[PostRead]:
    query = (
        select(Post)
        .options(selectinload(Post.author))
        .join(PostSave, PostSave.post_id == Post.id)
        .where(PostSave.user_id == current.id)
        .order_by(desc(PostSave.created_at))
    )
    posts = list((await db.scalars(query)).all())
    return await _attach_user_flags(db, posts, current)


# =====================================================
# CRUD
# =====================================================


@router.get(
    "/{post_id}",
    response_model=PostRead,
    summary="Bitta post tafsilotlari",
)
async def get_post(
    post_id: UUID,
    db: DbSession,
    current: CurrentUserOptional,
) -> PostRead:
    post = await db.scalar(
        select(Post).options(selectinload(Post.author)).where(Post.id == post_id)
    )
    if post is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")
    flags = await _attach_user_flags(db, [post], current)
    return flags[0]


@router.post(
    "",
    response_model=PostRead,
    status_code=status.HTTP_201_CREATED,
    summary="Yangi post yaratish",
)
async def create_post(
    payload: PostCreate,
    current: CurrentUser,
    db: DbSession,
) -> PostRead:
    post = Post(
        author_id=current.id,
        **payload.model_dump(),
    )
    db.add(post)
    await db.commit()
    fresh = await db.scalar(
        select(Post).options(selectinload(Post.author)).where(Post.id == post.id)
    )
    return PostRead.model_validate(fresh)


@router.patch(
    "/{post_id}",
    response_model=PostRead,
    summary="Postni yangilash (faqat ega yoki admin)",
)
async def update_post(
    post_id: UUID,
    payload: PostUpdate,
    current: CurrentUser,
    db: DbSession,
) -> PostRead:
    post = await db.scalar(
        select(Post).options(selectinload(Post.author)).where(Post.id == post_id)
    )
    if post is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")

    if post.author_id != current.id and not current.is_moderator:
        raise HTTPException(status_code=403, detail="Bu postni yangilash huquqingiz yo'q")

    update_data = payload.model_dump(exclude_unset=True)
    if "is_published" in update_data and not current.is_moderator:
        # Faqat moderator/admin publish state'ni o'zgartira oladi
        update_data.pop("is_published")

    for field, value in update_data.items():
        setattr(post, field, value)

    await db.commit()
    # Eager re-fetch — `updated_at` (server onupdate) va boshqa attributelar
    # bilan birga, `author` ham eager loadable.
    fresh = await db.scalar(
        select(Post).options(selectinload(Post.author)).where(Post.id == post_id)
    )
    return PostRead.model_validate(fresh)


@router.delete(
    "/{post_id}",
    response_model=MessageResponse,
    summary="Postni o'chirish (ega yoki admin)",
)
async def delete_post(
    post_id: UUID,
    current: CurrentUser,
    db: DbSession,
) -> MessageResponse:
    post = await db.get(Post, post_id)
    if post is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")

    if post.author_id != current.id and not current.is_moderator:
        raise HTTPException(status_code=403, detail="Bu postni o'chirish huquqingiz yo'q")

    await db.delete(post)
    await db.commit()
    return MessageResponse(message="Post o'chirildi")


# =====================================================
# Toggle like / save
# =====================================================


@router.post(
    "/{post_id}/like",
    response_model=PostRead,
    summary="Postga layk qo'yish/olib tashlash (toggle)",
)
async def like_post(
    post_id: UUID,
    current: CurrentUser,
    db: DbSession,
) -> PostRead:
    post = await db.scalar(
        select(Post).options(selectinload(Post.author)).where(Post.id == post_id)
    )
    if post is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")

    is_now, _ = await posts_service.toggle_like(db, user_id=current.id, post_id=post_id)
    await db.refresh(post)

    result = PostRead.model_validate(post)
    result.is_liked = is_now
    result.is_saved = await posts_service.is_saved(db, user_id=current.id, post_id=post_id)
    return result


@router.post(
    "/{post_id}/save",
    response_model=PostRead,
    summary="Postni saqlash/olib tashlash (toggle)",
)
async def save_post(
    post_id: UUID,
    current: CurrentUser,
    db: DbSession,
) -> PostRead:
    post = await db.scalar(
        select(Post).options(selectinload(Post.author)).where(Post.id == post_id)
    )
    if post is None:
        raise HTTPException(status_code=404, detail="Post topilmadi")

    is_now = await posts_service.toggle_save(db, user_id=current.id, post_id=post_id)
    result = PostRead.model_validate(post)
    result.is_saved = is_now
    result.is_liked = await posts_service.is_liked(db, user_id=current.id, post_id=post_id)
    return result
