"""User modeli."""

from __future__ import annotations

from datetime import datetime
from enum import StrEnum
from typing import TYPE_CHECKING

from sqlalchemy import BigInteger, Boolean, DateTime, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.comment import Comment
    from app.models.gallery import Gallery
    from app.models.post import Post


class UserRole(StrEnum):
    USER = "user"
    MODERATOR = "moderator"
    ADMIN = "admin"


class User(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "users"

    # Identification (kamida bitta bo'lishi shart)
    phone: Mapped[str | None] = mapped_column(String(32), unique=True, nullable=True)
    email: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    google_sub: Mapped[str | None] = mapped_column(String(64), unique=True, nullable=True)
    telegram_id: Mapped[int | None] = mapped_column(BigInteger, unique=True, nullable=True)

    # Profile
    fullname: Mapped[str] = mapped_column(String(100), nullable=False)
    img_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # Admin/moderator parol (faqat admin panel login uchun, bcrypt xeshlangan).
    # Mobile foydalanuvchilar uchun `null` — ular faqat OTP/Google bilan kirishadi.
    password_hash: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # Authorization
    role: Mapped[str] = mapped_column(String(20), nullable=False, default=UserRole.USER.value)
    is_banned: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    language: Mapped[str] = mapped_column(String(2), nullable=False, default="uz")

    # Push (kelajak)
    device_id: Mapped[str | None] = mapped_column(String(100), nullable=True)
    device_type: Mapped[str | None] = mapped_column(String(10), nullable=True)
    device_token: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # Activity
    last_login_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Relationships (back-populates)
    posts: Mapped[list["Post"]] = relationship(
        "Post", back_populates="author", cascade="all, delete-orphan"
    )
    comments: Mapped[list["Comment"]] = relationship(
        "Comment", back_populates="author", cascade="all, delete-orphan"
    )
    galleries: Mapped[list["Gallery"]] = relationship(
        "Gallery", back_populates="owner", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User id={self.id} fullname={self.fullname!r} role={self.role}>"

    @property
    def is_admin(self) -> bool:
        return self.role == UserRole.ADMIN.value

    @property
    def is_moderator(self) -> bool:
        return self.role in (UserRole.MODERATOR.value, UserRole.ADMIN.value)
