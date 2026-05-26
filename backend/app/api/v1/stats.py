"""Stats router — `/api/v1/stats/` (admin dashboard)."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Query
from typing import Annotated

from sqlalchemy import cast, Date, func, select

from app.api.deps import CurrentAdmin, DbSession
from app.models.comment import Comment
from app.models.gallery import Gallery
from app.models.post import Post
from app.models.user import User
from app.schemas.stats import CountByDay, CountByType, DashboardStats

router = APIRouter(prefix="/stats", tags=["stats"])


@router.get(
    "/dashboard",
    response_model=DashboardStats,
    summary="(Admin) Asosiy raqamlar",
)
async def dashboard(_admin: CurrentAdmin, db: DbSession) -> DashboardStats:
    today_start = datetime.now(UTC).replace(hour=0, minute=0, second=0, microsecond=0)

    total_users = await db.scalar(select(func.count(User.id))) or 0
    total_posts = await db.scalar(select(func.count(Post.id))) or 0
    total_comments = await db.scalar(select(func.count(Comment.id))) or 0
    total_galleries = await db.scalar(select(func.count(Gallery.id))) or 0

    new_users_today = await db.scalar(
        select(func.count(User.id)).where(User.created_at >= today_start)
    ) or 0
    new_posts_today = await db.scalar(
        select(func.count(Post.id)).where(Post.created_at >= today_start)
    ) or 0

    top_post_likes = await db.scalar(select(func.max(Post.like_count))) or 0
    banned_users = await db.scalar(
        select(func.count(User.id)).where(User.is_banned.is_(True))
    ) or 0

    return DashboardStats(
        total_users=total_users,
        total_posts=total_posts,
        total_comments=total_comments,
        total_galleries=total_galleries,
        new_users_today=new_users_today,
        new_posts_today=new_posts_today,
        top_post_likes=top_post_likes,
        banned_users=banned_users,
    )


@router.get(
    "/users-by-day",
    response_model=list[CountByDay],
    summary="(Admin) Kunlik signup grafik",
)
async def users_by_day(
    _admin: CurrentAdmin,
    db: DbSession,
    days: Annotated[int, Query(ge=1, le=365)] = 30,
) -> list[CountByDay]:
    since = datetime.now(UTC) - timedelta(days=days)
    day_col = cast(User.created_at, Date).label("day")

    query = (
        select(day_col, func.count(User.id).label("cnt"))
        .where(User.created_at >= since)
        .group_by(day_col)
        .order_by(day_col)
    )
    rows = (await db.execute(query)).all()
    return [CountByDay(date=row.day, count=row.cnt) for row in rows]


@router.get(
    "/posts-by-type",
    response_model=list[CountByType],
    summary="(Admin) Postlar turlari bo'yicha taqsimot",
)
async def posts_by_type(_admin: CurrentAdmin, db: DbSession) -> list[CountByType]:
    query = (
        select(Post.type, func.count(Post.id).label("cnt"))
        .group_by(Post.type)
        .order_by(func.count(Post.id).desc())
    )
    rows = (await db.execute(query)).all()
    return [CountByType(type=row.type, count=row.cnt) for row in rows]
