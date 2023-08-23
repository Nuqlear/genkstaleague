"""position_data_migration

Revision ID: 349ca011e79
Revises: 453209c819
Create Date: 2023-08-23 21:55:41.549588

"""

# revision identifiers, used by Alembic.
revision = "349ca011e79"
down_revision = "453209c819"
branch_labels = None
depends_on = None

import enum
from collections import OrderedDict
from collections import Counter
from typing import Optional, List
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from sqlalchemy_utils.types import ChoiceType


MID_THRESHOLD = 2000


class Position(enum.Enum):
    top = "top"
    bottom = "bottom"
    middle = "middle"
    roam = "roam"


def point_position(point: List[int]):
    if abs(point[0] - point[1]) < MID_THRESHOLD:
        return Position.middle
    if point[0] - point[1] < 0:
        return Position.top
    return Position.bottom


def detect_position(points: List[List[int]]) -> Optional[Position]:
    if not points:
        return None
    result = [point_position(point) for point in points]
    most_common, num_most_common = Counter(result).most_common(1)[0]
    if (len(points) / num_most_common) > 0.6:
        position = most_common
    else:
        position = Position.roam
    return position


v_player_match_stats = sa.Table(
    "player_match_stats",
    sa.MetaData(),
    sa.Column("id", sa.Integer),
    sa.Column("position", ChoiceType(Position)),
    sa.Column("movement", postgresql.JSONB),
)


def upgrade():
    op.execute("UPDATE season_stats SET inactive = false")

    connection = op.get_bind()
    results = connection.execute(
        sa.select(
            [
                v_player_match_stats.c.id,
                v_player_match_stats.c.position,
                v_player_match_stats.c.movement,
            ]
        )
        .where(v_player_match_stats.c.movement.isnot(None))
    ).fetchall()

    for id_, _, movement in results:
        pos = detect_position(list([[pos["x"], pos["y"]] for pos in movement]))
        connection.execute(
            v_player_match_stats.update()
            .where(v_player_match_stats.c.id == id_)
            .values(position=pos)
        )
