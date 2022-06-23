"""add_season_stats_inactive

Revision ID: 4b876680026
Revises: c8b48a1206
Create Date: 2022-06-23 11:38:59.313330

"""

# revision identifiers, used by Alembic.
revision = "4b876680026"
down_revision = "c8b48a1206"
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column("season_stats", sa.Column("inactive", sa.Boolean(), nullable=True))
    op.execute("UPDATE season_stats SET inactive = false")
    op.alter_column(
        "season_stats", "inactive", existing_type=sa.Boolean(), nullable=False
    )


def downgrade():
    op.drop_column("season_stats", "inactive")
