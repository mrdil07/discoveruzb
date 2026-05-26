"""Post modeli + layk va saqlash jadvallari."""

from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import (
    ARRAY,
    Boolean,
    DateTime,
    Double,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.dialects.postgresql import UUID as PgUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.comment import Comment
    from app.models.external_review import ExternalReview
    from app.models.user import User


class Post(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "posts"

    author_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    place_name: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    place_info: Mapped[str] = mapped_column(Text, nullable=False)
    address: Mapped[str] = mapped_column(String(300), nullable=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    source: Mapped[str | None] = mapped_column(String(300), nullable=True)
    price: Mapped[str | None] = mapped_column(String(100), nullable=True)

    phone_numbers: Mapped[list[str]] = mapped_column(
        ARRAY(String), nullable=False, default=list, server_default="{}"
    )
    images: Mapped[list[str]] = mapped_column(
        ARRAY(String), nullable=False, default=list, server_default="{}"
    )

    lat: Mapped[float] = mapped_column(Double, nullable=False)
    lon: Mapped[float] = mapped_column(Double, nullable=False)

    like_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    is_published: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    # Tashqi xarita platformalardagi joy ID lari (admin tomonidan o'rnatiladi).
    # Bularni bo'sh qoldirsa — tegishli platformadan reviewlar yig'ilmaydi.
    google_place_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    yandex_place_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    gis_place_id: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # Relationships
    author: Mapped["User"] = relationship("User", back_populates="posts")
    comments: Mapped[list["Comment"]] = relationship(
        "Comment", back_populates="post", cascade="all, delete-orphan"
    )
    external_reviews: Mapped[list["ExternalReview"]] = relationship(
        "ExternalReview", back_populates="post", cascade="all, delete-orphan"
    )
    likes: Mapped[list["PostLike"]] = relationship(
        "PostLike", back_populates="post", cascade="all, delete-orphan"
    )
    saves: Mapped[list["PostSave"]] = relationship(
        "PostSave", back_populates="post", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Post id={self.id} place_name={self.place_name!r}>"


class PostLike(Base):
    __tablename__ = "post_likes"

    user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    post_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("posts.id", ondelete="CASCADE"),
        primary_key=True,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    post: Mapped["Post"] = relationship("Post", back_populates="likes")


class PostSave(Base):
    __tablename__ = "post_saves"

    user_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    post_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("posts.id", ondelete="CASCADE"),
        primary_key=True,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    post: Mapped["Post"] = relationship("Post", back_populates="saves")
