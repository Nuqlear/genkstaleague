import datetime

from sqlalchemy import Integer
from sqlalchemy import ForeignKey
from sqlalchemy import Column
from sqlalchemy import DateTime
from sqlalchemy import BigInteger
from sqlalchemy import Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.orm import backref
from sqlalchemy.dialects import postgresql

from gleague.core import db


class TeamSeed(db.Model):
    __tablename__ = "team_seed"

    id = Column(postgresql.UUID, primary_key=True)
    season_id = Column(
        Integer,
        ForeignKey("season.id"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, default=datetime.datetime.utcnow)

    season = relationship(
        "Season",
        backref="team_seeds",
    )


class TeamSeedPlayer(db.Model):
    __tablename__ = "team_seed_player"

    id = Column(Integer, primary_key=True)
    seed_id = Column(
        postgresql.UUID,
        ForeignKey("team_seed.id"),
        nullable=False,
    )
    steam_id = Column(
        BigInteger,
        ForeignKey("player.steam_id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=True,
    )
    is_radiant = Column(Boolean, nullable=False)
    is_double_down = Column(Boolean, nullable=False, default=False)

    player = db.relationship(
        "Player",
        backref=db.backref("seeds"),
    )
    seed = relationship(
        "TeamSeed",
        cascade="all,delete",
        backref=backref("team_seed_players", cascade="all, delete-orphan"),
    )
