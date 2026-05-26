"""initial schema

Revision ID: 0001_initial
Revises:
Create Date: 2026-05-10
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0001_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Extensions
    op.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto"')          # gen_random_uuid()
    op.execute('CREATE EXTENSION IF NOT EXISTS "pg_trgm"')           # qidiruv uchun

    # ===== users =====
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("phone", sa.String(32), nullable=True, unique=True),
        sa.Column("email", sa.String(255), nullable=True, unique=True),
        sa.Column("google_sub", sa.String(64), nullable=True, unique=True),
        sa.Column("telegram_id", sa.BigInteger, nullable=True, unique=True),
        sa.Column("fullname", sa.String(100), nullable=False),
        sa.Column("img_url", sa.String(500), nullable=True),
        sa.Column("role", sa.String(20), nullable=False, server_default="user"),
        sa.Column("is_banned", sa.Boolean, nullable=False, server_default=sa.text("false")),
        sa.Column("language", sa.String(2), nullable=False, server_default="uz"),
        sa.Column("device_id", sa.String(100), nullable=True),
        sa.Column("device_type", sa.String(10), nullable=True),
        sa.Column("device_token", sa.String(500), nullable=True),
        sa.Column("last_login_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_users_phone", "users", ["phone"], postgresql_where=sa.text("phone IS NOT NULL"))
    op.create_index("ix_users_email", "users", ["email"], postgresql_where=sa.text("email IS NOT NULL"))
    op.create_index("ix_users_role", "users", ["role"])

    # ===== posts =====
    op.create_table(
        "posts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("author_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("place_name", sa.String(200), nullable=False),
        sa.Column("place_info", sa.Text, nullable=False),
        sa.Column("address", sa.String(300), nullable=False),
        sa.Column("type", sa.String(50), nullable=False),
        sa.Column("source", sa.String(300), nullable=True),
        sa.Column("price", sa.String(100), nullable=True),
        sa.Column("phone_numbers", postgresql.ARRAY(sa.String), nullable=False,
                  server_default="{}"),
        sa.Column("images", postgresql.ARRAY(sa.String), nullable=False,
                  server_default="{}"),
        sa.Column("lat", sa.Double, nullable=False),
        sa.Column("lon", sa.Double, nullable=False),
        sa.Column("like_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("is_published", sa.Boolean, nullable=False, server_default=sa.text("true")),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_posts_author_id", "posts", ["author_id"])
    op.create_index("ix_posts_type", "posts", ["type"])
    op.create_index("ix_posts_place_name", "posts", ["place_name"])
    op.create_index("ix_posts_created_at", "posts", [sa.text("created_at DESC")])
    op.create_index("ix_posts_like_count", "posts", [sa.text("like_count DESC")])
    op.create_index("ix_posts_is_published", "posts", ["is_published"])
    op.execute("CREATE INDEX ix_posts_name_trgm ON posts USING gin (place_name gin_trgm_ops)")

    # ===== post_likes =====
    op.create_table(
        "post_likes",
        sa.Column("user_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("post_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("posts.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_post_likes_post_id", "post_likes", ["post_id"])

    # ===== post_saves =====
    op.create_table(
        "post_saves",
        sa.Column("user_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("post_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("posts.id", ondelete="CASCADE"), primary_key=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_post_saves_post_id", "post_saves", ["post_id"])

    # ===== comments =====
    op.create_table(
        "comments",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("post_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("posts.id", ondelete="CASCADE"), nullable=False),
        sa.Column("author_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("body", sa.Text, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_comments_post_id", "comments", ["post_id"])
    op.create_index("ix_comments_author_id", "comments", ["author_id"])

    # ===== galleries =====
    op.create_table(
        "galleries",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("place_name", sa.String(200), nullable=False),
        sa.Column("images", postgresql.ARRAY(sa.String), nullable=False,
                  server_default="{}"),
        sa.Column("date", sa.Date, nullable=True),
        sa.Column("is_public", sa.Boolean, nullable=False, server_default=sa.text("false")),
        sa.Column("share_slug", sa.String(32), nullable=True, unique=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_galleries_owner_id", "galleries", ["owner_id"])

    # ===== categories =====
    op.create_table(
        "categories",
        sa.Column("slug", sa.String(50), primary_key=True),
        sa.Column("name_uz", sa.String(100), nullable=False),
        sa.Column("name_ru", sa.String(100), nullable=False),
        sa.Column("name_en", sa.String(100), nullable=False),
        sa.Column("icon_url", sa.String(500), nullable=True),
        sa.Column("sort_order", sa.Integer, nullable=False, server_default="0"),
        sa.Column("is_active", sa.Boolean, nullable=False, server_default=sa.text("true")),
    )

    # ===== auth_otps =====
    op.create_table(
        "auth_otps",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("phone", sa.String(32), nullable=False),
        sa.Column("code_hash", sa.String(255), nullable=False),
        sa.Column("request_id", sa.String(100), nullable=True),
        sa.Column("attempts", sa.Integer, nullable=False, server_default="0"),
        sa.Column("verified", sa.Boolean, nullable=False, server_default=sa.text("false")),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_auth_otps_phone", "auth_otps", ["phone", sa.text("created_at DESC")])

    # ===== refresh_tokens =====
    op.create_table(
        "refresh_tokens",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("user_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("token_hash", sa.String(64), nullable=False, unique=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("user_agent", sa.String(500), nullable=True),
        sa.Column("ip_address", postgresql.INET, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
    )
    op.create_index("ix_refresh_tokens_user_id", "refresh_tokens", ["user_id"])


def downgrade() -> None:
    op.drop_table("refresh_tokens")
    op.drop_table("auth_otps")
    op.drop_table("categories")
    op.drop_table("galleries")
    op.drop_table("comments")
    op.drop_table("post_saves")
    op.drop_table("post_likes")
    op.drop_table("posts")
    op.drop_table("users")
    op.execute("DROP EXTENSION IF EXISTS pg_trgm")
    op.execute("DROP EXTENSION IF EXISTS pgcrypto")
