"""external reviews + place ids

Revision ID: 0002_external_reviews
Revises: 0001_initial
Create Date: 2026-05-11
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0002_external_reviews"
down_revision: Union[str, None] = "0001_initial"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ===== posts ga place ID lar =====
    op.add_column("posts", sa.Column("google_place_id", sa.String(255), nullable=True))
    op.add_column("posts", sa.Column("yandex_place_id", sa.String(255), nullable=True))
    op.add_column("posts", sa.Column("gis_place_id", sa.String(255), nullable=True))

    # ===== external_reviews =====
    op.create_table(
        "external_reviews",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("post_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("posts.id", ondelete="CASCADE"), nullable=False),
        sa.Column("source", sa.String(10), nullable=False),
        sa.Column("external_id", sa.String(255), nullable=False),
        sa.Column("author_name", sa.String(200), nullable=False),
        sa.Column("author_avatar_url", sa.String(500), nullable=True),
        sa.Column("author_profile_url", sa.String(500), nullable=True),
        sa.Column("rating", sa.Float, nullable=True),
        sa.Column("text", sa.Text, nullable=True),
        sa.Column("language", sa.String(5), nullable=True),
        sa.Column("posted_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("fetched_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
        sa.Column("helpful_count", sa.Integer, nullable=False, server_default="0"),
        sa.UniqueConstraint("post_id", "source", "external_id",
                            name="uq_external_reviews_post_source_external"),
    )
    op.create_index("ix_external_reviews_post_id", "external_reviews", ["post_id"])
    op.create_index("ix_external_reviews_source", "external_reviews", ["source"])

    # ===== place_fetch_logs =====
    op.create_table(
        "place_fetch_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True,
                  server_default=sa.text("gen_random_uuid()")),
        sa.Column("post_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("posts.id", ondelete="CASCADE"), nullable=False),
        sa.Column("source", sa.String(10), nullable=False),
        sa.Column("last_fetched_at", sa.DateTime(timezone=True), nullable=False,
                  server_default=sa.func.now()),
        sa.Column("review_count", sa.Integer, nullable=False, server_default="0"),
        sa.Column("average_rating", sa.Float, nullable=True),
        sa.Column("error", sa.Text, nullable=True),
        sa.UniqueConstraint("post_id", "source",
                            name="uq_place_fetch_logs_post_source"),
    )
    op.create_index("ix_place_fetch_logs_post_id", "place_fetch_logs", ["post_id"])


def downgrade() -> None:
    op.drop_table("place_fetch_logs")
    op.drop_table("external_reviews")
    op.drop_column("posts", "gis_place_id")
    op.drop_column("posts", "yandex_place_id")
    op.drop_column("posts", "google_place_id")
