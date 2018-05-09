"""return old tables name without dota

Revision ID: d143e925e4
Revises: 33b6e2c95ff
Create Date: 2017-05-28 20:14:58.408304

"""

# revision identifiers, used by Alembic.
revision = 'd143e925e4'
down_revision = '33b6e2c95ff'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


def upgrade():
    op.rename_table('dota_player_match_stats', 'player_match_stats')
    op.rename_table('dota_player_match_rating', 'player_match_rating')
    op.rename_table('dota_match', 'match')
    op.rename_table('dota_season', 'season')
    op.rename_table('dota_season_stats', 'season_stats')


def downgrade():
    op.rename_table('player_match_stats', 'dota_player_match_stats')
    op.rename_table('player_match_rating', 'dota_player_match_rating')
    op.rename_table('match', 'dota_match')
    op.rename_table('season', 'dota_season')
    op.rename_table('season_stats', 'dota_season_stats')
