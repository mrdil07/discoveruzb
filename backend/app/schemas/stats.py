"""Stats Pydantic schema'lari (admin dashboard)."""

from __future__ import annotations

from datetime import date

from pydantic import BaseModel


class DashboardStats(BaseModel):
    total_users: int
    total_posts: int
    total_comments: int
    total_galleries: int
    new_users_today: int
    new_posts_today: int
    top_post_likes: int
    banned_users: int


class CountByDay(BaseModel):
    date: date
    count: int


class CountByType(BaseModel):
    type: str
    count: int
