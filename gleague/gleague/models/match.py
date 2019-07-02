import enum

import requests
from flask import current_app
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
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.schema import CheckConstraint
from sqlalchemy.schema import UniqueConstraint
from sqlalchemy_utils.types import ChoiceType
from werkzeug.utils import cached_property

from gleague.core import db
from gleague.models.season import SeasonStats
from gleague.utils.position import Position, detect_position


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
    movement = Column(JSONB, nullable=True)
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

    def is_winner(self):
        return self.match.radiant_win == (self.player_slot < 5)


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
    cm_picks_bans = relationship(
        "CMPicksBans", cascade="all,delete", backref="match", order_by=CMPicksBans.id
    )
    cm_captains = Column(ARRAY(Integer))
    players_stats = relationship(
        "PlayerMatchStats",
        cascade="all,delete",
        backref="match",
        order_by=PlayerMatchStats.player_slot,
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

    @staticmethod
    def create_from_replay_fs(replay_fs):
        resp = requests.post(
            url="http://dem2json:5222",
            data=replay_fs.read(),
            headers={"Content-Type": "application/octet-stream"},
        )
        return Match.create_from_dict(resp.json()["result"])

    @staticmethod
    def create_from_dict(match_data):
        from gleague.models.player import Player
        from gleague.models.season import Season

        base_pts_diff = current_app.config.get("MATCH_BASE_PTS_DIFF", 20)

        match = Match()
        match.season_id = Season.current().id
        match.id = match_data["match_id"]
        match.radiant_win = bool(match_data["radiant_win"])
        for key in ("duration", "game_mode", "start_time"):
            setattr(match, key, match_data[key])
        db.session.add(match)
        if match.game_mode == 2:
            match.cm_captains = match_data["draft"]["captains"]
            for pick_ban_data in match_data["draft"]["picks_and_bans"]:
                db.session.add(
                    CMPicksBans(
                        is_pick=pick_ban_data["is_pick"],
                        is_radiant=pick_ban_data["is_radiant"],
                        hero=pick_ban_data["hero"],
                        match_id=match.id,
                    )
                )
        for player_data in match_data["players"]:
            player_stats = PlayerMatchStats()
            account_id = "765" + str(player_data["account_id"] + 61197960265728)
            player = Player.get_or_create(account_id)
            if player is None:
                db.session.rollback()
                return None
            db.session.flush()
            season_stats = SeasonStats.get_or_create(account_id, match.season_id)
            player_stats.pts_diff = 20
            player_stats.season_stats_id = season_stats.id
            for key in (
                "kills",
                "assists",
                "level",
                "deaths",
                "hero_damage",
                "last_hits",
                "player_slot",
                "denies",
                "tower_damage",
                "damage_taken",
                "xp_per_min",
                "gold_per_min",
                "movement",
                "early_denies",
                "early_last_hits",
                "observer_wards_placed",
                "sentry_wards_placed",
            ):
                setattr(player_stats, key, player_data[key])
            player_stats.hero = player_data["hero_name"].replace("npc_dota_hero_", "")
            player_stats.position = detect_position(
                list([[pos["x"], pos["y"]] for pos in player_stats.movement])
            )
            for item in player_data["items"]:
                if item:
                    db.session.add(
                        PlayerMatchItem(name=item, player_match_stats=player_stats)
                    )
            player_stats.match_id = match.id
            db.session.add(player_stats)
            db.session.add(season_stats)
            player_stats.old_pts = season_stats.pts
        sort_by_lh = lambda s: s.early_last_hits  # noqa
        radiant_players = sorted(
            filter(lambda s: s.player_slot < 5, match.players_stats), key=sort_by_lh
        )
        dire_players = sorted(
            filter(lambda s: s.player_slot > 5, match.players_stats), key=sort_by_lh
        )
        supports_number = 2
        supports = radiant_players[:supports_number] + dire_players[:supports_number]
        cores = radiant_players[supports_number:] + dire_players[supports_number:]
        for sup in supports:
            sup.role = Role.support
        for core in cores:
            core.role = Role.core
        pts = dict(radiant=0, dire=0)
        for stats in match.players_stats:
            if stats.player_slot < 5:
                pts["radiant"] += stats.season_stats.pts
            else:
                pts["dire"] += stats.season_stats.pts
        pts_deviation = int(abs(pts["radiant"] - pts["dire"]) / 20)
        if pts_deviation > base_pts_diff - 5:
            pts_deviation = base_pts_diff - 5
        pts_diff = base_pts_diff
        if (pts["dire"] > pts["radiant"]) == match.radiant_win:
            pts_diff += pts_deviation
        else:
            pts_diff -= pts_deviation
        for stats in match.players_stats:
            if stats.is_winner():
                stats.pts_diff = pts_diff
            else:
                stats.pts_diff = -pts_diff
            stats.season_stats.pts += stats.pts_diff
        for stats in match.players_stats:
            season_stats = stats.season_stats
            if stats.pts_diff > 0:
                season_stats.wins += 1
                if season_stats.streak > 0:
                    season_stats.streak += 1
                else:
                    season_stats.streak = 1
                if season_stats.streak > season_stats.longest_winstreak:
                    season_stats.longest_winstreak = season_stats.streak
            else:
                if season_stats.streak > 0:
                    season_stats.streak = -1
                else:
                    season_stats.streak -= 1
                season_stats.losses += 1
                if season_stats.streak < -(season_stats.longest_losestreak):
                    season_stats.longest_losestreak = -(season_stats.streak)
        db.session.add(match)
        db.session.flush()
        return match
