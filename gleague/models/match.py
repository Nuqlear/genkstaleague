import json

from sqlalchemy import (Column, String, Integer, ForeignKey, Boolean, BigInteger, SmallInteger, desc, func, 
    and_, or_)
from sqlalchemy.schema import CheckConstraint, UniqueConstraint
from sqlalchemy.orm import relationship
from flask import current_app

from gleague.core import db
from gleague.models import SeasonStats, Player, Season
from ..utils.steam_api import get_dota2_heroes


class PlayerMatchStats(db.Model):
    __tablename__ = 'player_match_stats'

    id = Column(Integer, primary_key=True)
    season_stats_id = Column(Integer, ForeignKey('season_stats.id', onupdate="CASCADE", 
                                                    ondelete="CASCADE"), nullable=False)
    match_id = Column(BigInteger, ForeignKey('match.id', onupdate="CASCADE", 
                                                    ondelete="CASCADE"), nullable=False)
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
    player_match_ratings = relationship('PlayerMatchRating', cascade="all, delete", 
                                                            backref="player_match_stats")

    def to_dict(self, extensive=True, **kwargs):
        with_season_stats = kwargs.get('with_season_stats', False)
        d = {
            'id': self.id,
            'player_slot': self.player_slot,
            'self.hero': self.hero
        }
        if extensive:
            d.update({
                'old_pts': self.old_pts,
                'kills': self.kills,
                'assists': self.assists,
                'deaths': self.deaths,
                'hero_damage': self.hero_damage,
                'denies': self.denies,
                'tower_damage': self.tower_damage,
                'self.hero_healing': self.hero_healing,
                'self.level': self.level
            })
            if with_season_stats:
                d['season_stats'] = self.season_stats.to_dict(True)
        else:
            d.update({
                'player_nickname': self.season_stats.player.nickname
            })
        return d


class PlayerMatchRating(db.Model):
    __tablename__ = 'player_match_rating'

    id = Column(Integer, primary_key=True)
    rated_by_steam_id = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", 
                                                                ondelete="CASCADE"), nullable=False)
    rating = Column(SmallInteger, default=5)
    player_match_stats_id = Column(Integer, ForeignKey('player_match_stats.id', onupdate="CASCADE", 
                                                                ondelete="CASCADE"), nullable=False)

    __table_args__ = (
        CheckConstraint('player_match_rating.rating >= 1'),
        CheckConstraint('player_match_rating.rating <= 5'),
        UniqueConstraint('rated_by_steam_id', 'player_match_stats_id', name='rated_once')
    )

    @staticmethod
    def get_match_ratings(match_id, user_id=None):
        # TODO: pure sqlalchemy
        rated_by_ps = played = None
        if user_id:
            rated_by_ps = PlayerMatchStats.query.join(SeasonStats).filter(and_(SeasonStats.steam_id==user_id, 
                PlayerMatchStats.match_id==match_id)).first()
            played = (rated_by_ps is not None)
        ratings = {}
        m = Match.query.get(match_id)
        for ps in m.players_stats:
            ratings[ps.id] = {'allowed_rate':played and ps.id != rated_by_ps.id and not(
                    PlayerMatchRating.query.filter(and_(PlayerMatchRating.rated_by_steam_id==user_id, 
                    PlayerMatchRating.player_match_stats_id==ps.id)).first()),
                'avg_rating':PlayerMatchRating.query.join(PlayerMatchStats).filter(PlayerMatchStats.id==ps.id)\
                .value(func.avg(PlayerMatchRating.rating))}
        return ratings


class Match(db.Model):
    __tablename__ = 'match'

    id = Column(BigInteger, primary_key=True)
    season_id = Column(Integer, ForeignKey('season.id', onupdate="CASCADE", ondelete="CASCADE"),
                                                                                nullable=False)
    players_stats = relationship('PlayerMatchStats', cascade="all,delete", backref="match", 
         order_by=PlayerMatchStats.player_slot)
    radiant_win = Column(Boolean)
    duration = Column(Integer)
    game_mode = Column(Integer)
    start_time = Column(Integer)
    base_pts_diff = 20

    def __repr__(self):
        return "%s" % self.id

    def to_dict(self, extensive=True):
        d = {
            'id': self.id,
            'season_number': self.season.number,
            'start_time': self.start_time,
            'game_mode': self.game_mode,
            'duration': self.duration,
            'radiant_win': self.radiant_win,
            'players_stats': [ps.to_dict(extensive) for ps in self.players_stats]
        }
        return d

    @staticmethod
    def is_exists(id):
        return bool(Match.query.get(id))

    def is_played(self, steam_id):
        return steam_id in (ps.season_stats.steam_id for ps in self.players_stats)

    @staticmethod
    def get_batch(amount, offset):
        q = Match.query.order_by(desc(Match.start_time)).limit(amount).offset(amount*offset)
        return q

    @staticmethod
    def create_from_dict(steamdata):
        m = Match()
        m.season_id = Season.current().id
        m.id = steamdata['match_id']
        m.radiant_win = bool(steamdata['radiant_win'])
        m.duration = steamdata['duration']
        m.game_mode = steamdata['game_mode']
        m.start_time = steamdata['start_time']
        db.session.add(m)
        heroes = get_dota2_heroes(current_app.config['STEAM_API_KEY'])
        for i in steamdata['players']:
            player_stats = PlayerMatchStats()
            account_id = '765' + str(i['account_id'] + 61197960265728)
            player = Player.get_or_create(account_id)
            if player is None:
                db.session.rollback()
                return None
            db.session.flush()
            season_stats = player.season_stats[-1]
            player_stats.season_stats_id = season_stats.id
            player_stats.kills = i['kills']
            player_stats.hero_healing = i['hero_healing']
            player_stats.assists = i['assists']
            player_stats.level = i['level']
            player_stats.pts_diff = 20
            player_stats.deaths = i['deaths']
            player_stats.hero_damage = i['hero_damage']
            player_stats.last_hits = i['last_hits']
            player_stats.player_slot = i['player_slot']
            player_stats.denies = i['denies']
            player_stats.tower_damage = i['tower_damage']
            player_stats.hero = heroes[i['hero_id']].replace('npc_dota_hero_', '')
            player_stats.match_id = m.id
            db.session.add(player_stats)
            db.session.add(season_stats)
            player_stats.old_pts = season_stats.pts
        pts = {'radiant': 0, 'dire':0}
        for i in range(len(m.players_stats)):
            j = m.players_stats[i]
            if j.player_slot < 5:
                pts['radiant'] += j.season_stats.pts
            else: pts['dire'] += j.season_stats.pts
        pts_diff = abs(pts['radiant'] - pts['dire'])/20
        if pts_diff > m.base_pts_diff-5: pts_diff = m.base_pts_diff-5
        # VERY OLD CODE; NEED REWORK
        if pts['radiant'] > pts['dire']:
            if m.radiant_win:
                for i in range(len(m.players_stats)):
                    j = m.players_stats[i]
                    if j.player_slot < 5:
                        j.pts_diff = int(m.base_pts_diff - pts_diff)
                    else:
                        j.pts_diff = -int(m.base_pts_diff - pts_diff)
                    j.season_stats.pts += j.pts_diff
            else:
                for i in range(len(m.players_stats)):
                    j = m.players_stats[i]
                    if j.player_slot < 5:
                        j.pts_diff = -int(m.base_pts_diff + pts_diff)
                    else:
                        j.pts_diff = int(m.base_pts_diff + pts_diff)
                    j.season_stats.pts += j.pts_diff
        else:
            if m.radiant_win:
                for i in range(len(m.players_stats)):
                    j = m.players_stats[i]
                    if j.player_slot < 5:
                        j.pts_diff = int(m.base_pts_diff + pts_diff)
                    else: 
                        j.pts_diff = -int(m.base_pts_diff + pts_diff)
                    j.season_stats.pts += j.pts_diff
            else:
                for i in range(len(m.players_stats)):
                    j = m.players_stats[i]
                    if j.player_slot < 5:
                        j.pts_diff = -int(m.base_pts_diff - pts_diff)
                    else: 
                        j.pts_diff = int(m.base_pts_diff - pts_diff)
                    j.season_stats.pts += j.pts_diff
        for i in range(len(m.players_stats)):
            stats = m.players_stats[i]
            season_stats = stats.season_stats
            if stats.pts_diff > 0:
                season_stats.wins += 1
                season_stats.streak += 1
                if season_stats.streak > season_stats.longest_streak:
                    season_stats.longest_streak = season_stats.streak
            else:
                season_stats.streak = 0 
                season_stats.losses += 1
        db.session.add(m)
        db.session.commit()
        return m
        