import json
import socket
import io

from sqlalchemy import Column
from sqlalchemy import String
from sqlalchemy import Integer
from sqlalchemy import ForeignKey
from sqlalchemy import BigInteger
from sqlalchemy import func
from sqlalchemy import case
from sqlalchemy import desc
from sqlalchemy import and_
from sqlalchemy.orm import relationship
from flask import current_app

from gleague.core import db
from gleague.models.dota.season import DotaSeason
from gleague.models.dota.season import DotaSeasonStats
from gleague.models.dota.match import DotaPlayerMatchStats
from gleague.utils.steam_api import get_steam_user_info


socket.setdefaulttimeout(120)


class Player(db.Model):
    __tablename__ = 'player'

    steam_id = Column(BigInteger, primary_key=True)
    nickname = Column(String(80))
    avatar = Column(String(255))
    avatar_medium = Column(String(255))
    dota_season_stats = relationship('DotaSeasonStats', lazy='dynamic', backref='player', order_by="desc(DotaSeasonStats.season_id)")

    def __repr__(self):
        return '{} ({})'.format(self.nickname, self.steam_id)

    def to_dict(self, extensive=True):
        d = {
            'steam_id': self.steam_id,
            'nickname': self.nickname,
        }
        if extensive:
            d.update({
                'avatar': self.avatar,
                'avatar_medium': self.avatar_medium,
                'dota_season_stats': [ss.to_dict() for ss in self.dota_season_stats]
            })
        return d

    @staticmethod
    def get_or_create(steam_id):
        p = Player.query.filter_by(steam_id=steam_id).first()
        if p is None:
            steamdata = {}
            steamdata = get_steam_user_info(steam_id, current_app.config['STEAM_API_KEY'])
            if steamdata == {}:
                return None
            p = DotaPlayer()
            p.steam_id = steam_id
            p.nickname = steamdata['personaname']
            p.avatar = steamdata['avatar']
            p.avatar_medium = steamdata['avatarmedium']
            db.session.add(p)
            db.session.flush()
        else:
            p.update_from_steam()
        return p

    def is_admin(self):
        return self.steam_id in current_app.config.get('ADMINS_STEAM_ID', [])

    def update_from_steam(self):
        steamdata = get_steam_user_info(self.steam_id, current_app.config['STEAM_API_KEY'])
        if steamdata == {}:
            return
        self.nickname = steamdata['personaname']
        self.avatar = steamdata['avatar']
        self.avatar_medium = steamdata['avatarmedium']


class DotaPlayer(Player):

    @staticmethod
    def get_or_create(steam_id):
        cs = DotaSeason.current()
        p = Player.get_or_create(steam_id)
        p.__class__ = DotaPlayer
        last_season_stats = p.dota_season_stats.first()
        if not last_season_stats or last_season_stats.season_id != cs.id:
            db.session.add(DotaSeasonStats(season_id=cs.id, steam_id=p.steam_id))
        db.session.flush()
        return p

    def get_avg_rating(self):
        from gleague.models.dota.match import DotaPlayerMatchRating
        q_res = DotaPlayerMatchRating.query.join(DotaPlayerMatchStats).join(DotaSeasonStats).filter(
            DotaSeasonStats.steam_id==self.steam_id).with_entities(func.avg(DotaPlayerMatchRating.rating), 
            func.count(DotaPlayerMatchRating.id)).all()
        return q_res
        
    def get_heroes(self, cs_id=None):
        filters = DotaSeasonStats.steam_id==self.steam_id
        if cs_id is not None:
            filters = and_(filters, DotaSeasonStats.season_id==cs_id)
        q_res = DotaPlayerMatchStats.query.join(DotaSeasonStats).filter(filters)\
            .with_entities(DotaPlayerMatchStats.hero.label('hero'), func.count(DotaPlayerMatchStats.id).label('played'), 
                (100 * func.sum(case([(DotaPlayerMatchStats.pts_diff>0, 1)], else_=0))/func.count(DotaPlayerMatchStats.id)).label('winrate'),
                func.sum(DotaPlayerMatchStats.pts_diff).label('pts_diff'),
                ((func.avg(DotaPlayerMatchStats.kills) + func.avg(DotaPlayerMatchStats.assists))/
                    func.avg(DotaPlayerMatchStats.deaths+1)).label('kda'), 
            ).group_by(DotaPlayerMatchStats.hero)
        return q_res
