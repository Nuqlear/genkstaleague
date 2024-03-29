"""team_seed

Revision ID: 4a6a586ab8d
Revises: 4b876680026
Create Date: 2023-04-02 15:00:47.227059

"""

# revision identifiers, used by Alembic.
revision = "4a6a586ab8d"
down_revision = "4b876680026"
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.create_table(
        "team_seed",
        sa.Column("id", postgresql.UUID(), nullable=False),
        sa.Column("season_id", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(
            ["season_id"], ["season.id"], onupdate="CASCADE", ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_table(
        "team_seed_player",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("seed_id", postgresql.UUID(), nullable=False),
        sa.Column("steam_id", sa.BigInteger(), nullable=True),
        sa.Column("is_radiant", sa.Boolean(), nullable=False),
        sa.Column("is_double_down", sa.Boolean(), nullable=False),
        sa.ForeignKeyConstraint(
            ["seed_id"], ["team_seed.id"], onupdate="CASCADE", ondelete="CASCADE"
        ),
        sa.ForeignKeyConstraint(
            ["steam_id"], ["player.steam_id"], onupdate="CASCADE", ondelete="CASCADE"
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.add_column("match", sa.Column("team_seed_id", postgresql.UUID(), nullable=True))
    op.create_foreign_key(
        "match_team_seed_id_fkey",
        "match",
        "team_seed",
        ["team_seed_id"],
        ["id"],
        ondelete="RESTRICT",
    )
    op.add_column("player_match_stats", sa.Column("is_double_down", sa.Boolean(), nullable=True))
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.drop_constraint("match_team_seed_id_fkey", "match", type_="foreignkey")
    op.drop_column("match", "team_seed_id")
    op.drop_column("player_match_stats", "is_double_down")
    op.drop_table("team_seed_player")
    op.drop_table("team_seed")
    ### end Alembic commands ###
