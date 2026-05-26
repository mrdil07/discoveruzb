"""SQLAlchemy ORM model'lari.

Hammasini bir joydan import qilamiz — Alembic autogenerate `Base.metadata`'ni
to'liq ko'rishi uchun.
"""

from app.db.base import Base
from app.models.auth import AuthOtp, RefreshToken
from app.models.category import Category
from app.models.comment import Comment
from app.models.external_review import ExternalReview, PlaceFetchLog, ReviewSource
from app.models.gallery import Gallery
from app.models.post import Post, PostLike, PostSave
from app.models.user import User, UserRole

__all__ = [
    "AuthOtp",
    "Base",
    "Category",
    "Comment",
    "ExternalReview",
    "Gallery",
    "PlaceFetchLog",
    "Post",
    "PostLike",
    "PostSave",
    "RefreshToken",
    "ReviewSource",
    "User",
    "UserRole",
]
