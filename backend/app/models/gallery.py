"""Gallery modeli."""

from __future__ import annotations

from datetime import date
from typing import TYPE_CHECKING
from uuid import UUID

from sqlalchemy import ARRAY, Boolean, Date, ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID as PgUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDPrimaryKeyMixin

if TYPE_CHECKING:
    from app.models.user import User


class Gallery(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "galleries"

    owner_id: Mapped[UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    place_name: Mapped[str] = mapped_column(String(200), nullable=False)
    images: Mapped[list[str]] = mapped_column(
        ARRAY(String), nullable=False, default=list, server_default="{}"
    )
    date: Mapped[date | None] = mapped_column(Date, nullable=True)
    is_public: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    share_slug: Mapped[str | None] = mapped_column(
        String(32), unique=True, nullable=True
    )

    owner: Mapped["User"] = relationship("User", back_populates="galleries")
