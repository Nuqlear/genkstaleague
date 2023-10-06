import enum

from sqlalchemy import BigInteger
from sqlalchemy import Boolean
from sqlalchemy import Column
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import SmallInteger
from sqlalchemy import String
from sqlalchemy import and_
from sqlalchemy import desc
from sqlalchemy import func
from sqlalchemy.dialects import postgresql
from sqlalchemy.orm import relationship
from sqlalchemy.orm import backref
from sqlalchemy.schema import CheckConstraint
from sqlalchemy.schema import UniqueConstraint
from sqlalchemy_utils.types import ChoiceType
from werkzeug.utils import cached_property

from gleague.core import db
from gleague.utils.position import Position


class Role(enum.Enum):
    core = "core"
    support = "support"


class PlayerMatchItem(db.Model):
    __tablename__ = "player_match_item"
    id = Column(Integer, primary_key=True)
    player_match_stats_id = Column(
        Integer,
        ForeignKey("player_match_stats.id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=False,
    )
    name = Column(String(255), nullable=False)

    def __repr__(self):
        return self.name

    @cached_property
    def image_url(self):
        return (
            "http://cdn.dota2.com/apps/dota2/images/items/%s_lg.png"
            % self.name.replace("item_", "")
        )


class PlayerMatchStats(db.Model):
    __tablename__ = "player_match_stats"

    id = Column(Integer, primary_key=True)
    season_stats_id = Column(
        Integer,
        ForeignKey("season_stats.id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=False,
    )
    match_id = Column(
        BigInteger,
        ForeignKey("match.id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=False,
    )
    is_double_down = Column(Boolean, nullable=True, default=False)
    old_pts = Column(Integer, nullable=False)
    pts_diff = Column(Integer, nullable=False)
    kills = Column(Integer, nullable=False)
    assists = Column(Integer, nullable=False)
    deaths = Column(Integer, nullable=False)
    hero_damage = Column(Integer, nullable=False)
    last_hits = Column(Integer, nullable=False)
    player_slot = Column(Integer, nullable=False)
    denies = Column(Integer, nullable=False)
    tower_damage = Column(Integer)
    hero = Column(String(255), nullable=False)
    hero_healing = Column(Integer)
    level = Column(Integer, nullable=False)
    xp_per_min = Column(Integer, nullable=True)
    gold_per_min = Column(Integer, nullable=True)
    damage_taken = Column(Integer, nullable=True)
    movement = Column(postgresql.JSONB, nullable=True)
    xp = Column(postgresql.JSONB, nullable=True)
    networth = Column(postgresql.JSONB, nullable=True)
    position = Column(ChoiceType(Position))
    role = Column(ChoiceType(Role))
    observer_wards_placed = Column(Integer)
    sentry_wards_placed = Column(Integer)
    early_last_hits = Column(Integer)
    early_denies = Column(Integer)
    player_match_ratings = relationship(
        "PlayerMatchRating", cascade="all, delete", backref="player_match_stats"
    )
    player_match_items = relationship(
        "PlayerMatchItem", cascade="all, delete", backref="player_match_stats"
    )

    def __repr__(self):
        return "%s (%s) -- Match %s" % (
            self.season_stats.player.nickname,
            self.season_stats.steam_id,
            self.match_id,
        )

    def is_radiant(self):
        return self.player_slot < 5

    def is_winner(self):
        return self.match.radiant_win == self.is_radiant()


class PlayerMatchRating(db.Model):
    __tablename__ = "player_match_rating"

    id = Column(Integer, primary_key=True)
    rated_by_steam_id = Column(
        BigInteger,
        ForeignKey("player.steam_id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=False,
    )
    rating = Column(SmallInteger, default=5)
    player_match_stats_id = Column(
        Integer,
        ForeignKey("player_match_stats.id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=False,
    )

    __table_args__ = (
        CheckConstraint("player_match_rating.rating >= 1"),
        CheckConstraint("player_match_rating.rating <= 5"),
        UniqueConstraint(
            "rated_by_steam_id", "player_match_stats_id", name="rated_once"
        ),
    )

    @staticmethod
    def get_match_ratings(match_id, user_id=None):
        from gleague.models.season import SeasonStats

        # TODO: pure sqlalchemy
        rated_by_ps = played = None
        if user_id:
            rated_by_ps = (
                PlayerMatchStats.query.join(SeasonStats)
                .filter(
                    and_(
                        SeasonStats.steam_id == user_id,
                        PlayerMatchStats.match_id == match_id,
                    )
                )
                .first()
            )
            played = rated_by_ps is not None
        ratings = {}
        m = Match.query.get(match_id)
        for ps in m.players_stats:
            avg_rating = (
                PlayerMatchRating.query.join(PlayerMatchStats)
                .filter(PlayerMatchStats.id == ps.id)
                .value(func.avg(PlayerMatchRating.rating))
            )
            if avg_rating:
                avg_rating = float(avg_rating) or 0.0
            rated_already = db.session.query(
                PlayerMatchRating.query.filter(
                    and_(
                        PlayerMatchRating.rated_by_steam_id == user_id,
                        PlayerMatchRating.player_match_stats_id == ps.id,
                    )
                ).exists()
            ).scalar()
            ratings[ps.id] = {
                "allowed_rate": (
                    played and ps.id != rated_by_ps.id and not rated_already
                ),
                "avg_rating": avg_rating,
            }
        return ratings


class CMPicksBans(db.Model):
    __tablename__ = "cm_picks_bans"
    id = Column(Integer, primary_key=True)
    is_pick = Column(Boolean, nullable=False)
    is_radiant = Column(Boolean, nullable=False)
    hero = Column(String(255), nullable=False)
    match_id = Column(
        BigInteger,
        ForeignKey("match.id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=False,
    )
    __table_args__ = (
        UniqueConstraint("hero", "match_id", name="cm_picks_bans_hero_match"),
    )

    @property
    def hero_img(self):
        return self.hero.replace("npc_dota_hero_", "")


class Match(db.Model):
    __tablename__ = "match"

    id = Column(BigInteger, primary_key=True)
    season_id = Column(
        Integer,
        ForeignKey("season.id", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=False,
    )
    team_seed_id = Column(
        postgresql.UUID,
        ForeignKey("team_seed.id"),
        nullable=True,
    )
    cm_picks_bans = relationship(
        "CMPicksBans", cascade="all,delete", backref="match", order_by=CMPicksBans.id
    )
    cm_captains = Column(postgresql.ARRAY(Integer))
    players_stats = relationship(
        "PlayerMatchStats",
        cascade="all,delete",
        backref="match",
        order_by=PlayerMatchStats.player_slot,
    )
    team_seed = relationship(
        "TeamSeed",
        backref=backref("match", uselist=False),
    )
    radiant_win = Column(Boolean)
    duration = Column(Integer)
    game_mode = Column(Integer)
    start_time = Column(Integer)

    game_modes_dict = {
        1: "All Pick",
        2: "Captains Mode",
        3: "Random Draft",
        4: "Single Draft",
        5: "All Random",
        8: "Reverse Captain Mode",
        16: "Captains Draft",
        22: "Ranked All Pick",
    }

    def __repr__(self):
        return "%s" % self.id

    @staticmethod
    def is_exists(id):
        return bool(Match.query.get(id))

    def is_played(self, steam_id):
        return steam_id in (ps.season_stats.steam_id for ps in self.players_stats)

    def game_mode_string(self):
        return self.game_modes_dict.get(self.game_mode, "unknown")

    def winner_string(self):
        return "Radiant" if self.radiant_win else "Dire"

    def duration_string(self):
        return "{}:{:02d}".format(self.duration // 60, self.duration % 60)

    @staticmethod
    def get_batch(amount, offset):
        q = (
            Match.query.order_by(desc(Match.start_time))
            .limit(amount)
            .offset(amount * offset)
        )
        return q
