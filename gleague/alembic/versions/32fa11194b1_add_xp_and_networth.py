"""add_xp_and_networth

Revision ID: 32fa11194b1
Revises: 349ca011e79
Create Date: 2023-10-06 22:02:16.436903

"""

# revision identifiers, used by Alembic.
revision = '32fa11194b1'
down_revision = '349ca011e79'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


def upgrade():
    op.add_column("player_match_stats", sa.Column("xp", postgresql.JSONB(), nullable=True))
    op.add_column("player_match_stats", sa.Column("networth", postgresql.JSONB(), nullable=True))


def downgrade():
    op.drop_column("player_match_stats", "xp")
    op.drop_column("player_match_stats", "networth")
