import json
import socket
import io

from sqlalchemy import Column, String, Integer, ForeignKey, BigInteger
from sqlalchemy.orm import relationship
from flask import current_app

from ..core import db
from .season import Season, SeasonStats
from ..utils.steam_api import get_steam_user_info


socket.setdefaulttimeout(120)


class Player(db.Model):
    __tablename__ = 'player'

    steam_id = Column(BigInteger, primary_key=True)
    nickname = Column(String(80))
    avatar = Column(String(255))
    avatar_medium = Column(String(255))
    season_stats = relationship('SeasonStats', lazy='dynamic', backref='player')

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
                'season_stats': [ss.to_dict() for ss in self.season_stats]
            })
        return d


    @staticmethod
    def get_or_create(steam_id):
        cs = Season.current()
        p = Player.query.filter_by(steam_id=steam_id).first()
        if p is None:
            steamdata = {}
            steamdata = get_steam_user_info(steam_id, current_app.config['STEAM_API_KEY'])
            if steamdata == {}:
                return None
            p = Player()
            p.steam_id = steam_id
            p.nickname = steamdata['personaname']
            p.avatar = steamdata['avatar']
            p.avatar_medium = steamdata['avatarmedium']
            db.session.add(p)
            db.session.flush()
            db.session.add(SeasonStats(season_id=cs.id, steam_id=p.steam_id))
        else:
            p.update_from_steam()
            if p.season_stats[-1].season_id != cs.id:
                db.session.add(SeasonStats(season_id=cs.id, steam_id=p.steam_id))
        db.session.commit()
        return p

    def update_from_steam(self):
        steamdata = get_steam_user_info(self.steam_id, current_app.config['STEAM_API_KEY'])
        if steamdata == {}:
            return
        self.nickname = steamdata['personaname']
        self.avatar = steamdata['avatar']
        self.avatar_medium = steamdata['avatarmedium']
