import datetime

from sqlalchemy import Column
from sqlalchemy import Integer
from sqlalchemy import ForeignKey
from sqlalchemy import BigInteger
from sqlalchemy import DateTime
from sqlalchemy import func
from sqlalchemy import desc
from sqlalchemy import and_
from sqlalchemy.orm import relationship
from flask import current_app

from gleague.core import db


class DotaSeason(db.Model):
    __tablename__ = 'dota_season'
    
    id = Column(Integer, primary_key=True)
    number = Column(Integer, nullable=False, unique=True)
    started = Column(DateTime, default=datetime.datetime.utcnow)
    ended = Column(DateTime)
    season_stats = relationship('DotaSeasonStats', lazy='dynamic', backref='season', order_by="desc(DotaSeasonStats.season_id)")
    matches = relationship('DotaMatch', lazy='dynamic', backref='season')
    place_1 = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"))
    place_2 = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"))
    place_3 = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"))
    place_1_player = db.relationship('Player', foreign_keys='DotaSeason.place_1',
                              backref=db.backref('place_1_seasons', lazy='dynamic'))
    place_2_player = db.relationship('Player', foreign_keys='DotaSeason.place_2',
                              backref=db.backref('place_2_seasons', lazy='dynamic'))
    place_3_player = db.relationship('Player', foreign_keys='DotaSeason.place_3',
                              backref=db.backref('place_3_seasons', lazy='dynamic'))


    def __init__(self, *args, **kwargs):
        if 'number' not in kwargs:
            x = db.session.query(func.max(DotaSeason.number)).first()[0] or 0
            kwargs['number'] = 1 + x
        super(DotaSeason, self).__init__(*args, **kwargs)

    def __repr__(self):
        return '{} ({}-{})'.format(self.id, self.started, self.ended or '...')

    def to_dict(self):
        d = {
            'id': self.id,
            'number': self.number,
            'started': self.avatar,
            'ended': self.avatar_medium
        }
        return d

    @staticmethod
    def current():
        cs = DotaSeason.query.order_by(desc(DotaSeason.number)).first()
        return cs

    def end(self, date=None):
        if date is None:
            date = datetime.datetime.utcnow()
        self.ended = date
        stats = DotaSeasonStats.query.filter(and_(DotaSeasonStats.season_id==self.id, 
            (DotaSeasonStats.wins+DotaSeasonStats.losses)>current_app.config.get('SEASON_CALIBRATING_MATCHES_NUM', 0)))\
            .with_entities(DotaSeasonStats.steam_id,DotaSeasonStats.pts).order_by(desc(DotaSeasonStats.pts)).limit(3).all()
        for s in stats:
            self.place_1 = stats[0][0]
            self.place_2 = stats[1][0]
            self.place_3 = stats[2][0]

    @staticmethod
    def start_new():
        os = DotaSeason.current()
        ns = DotaSeason()
        if os:
            os.end()
            db.session.add(os)
        db.session.add(ns)
        db.session.flush()
        return ns


class DotaSeasonStats(db.Model):
    __tablename__ = 'dota_season_stats'
    
    id = Column(Integer, primary_key=True)
    season_id = Column(Integer, ForeignKey('dota_season.id', onupdate="CASCADE", ondelete="CASCADE"), nullable=False)
    steam_id = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"), nullable=False)
    wins = Column(Integer, default=0, nullable=False)
    losses = Column(Integer, default=0, nullable=False)
    pts = Column(Integer, default=1000, nullable=False)
    longest_winstreak = Column(Integer, default=0, nullable=False)
    longest_losestreak = Column(Integer, default=0, nullable=False)
    streak = Column(Integer, default=0, nullable=False)
    player_matches_stats = relationship('DotaPlayerMatchStats', lazy='dynamic', backref='season_stats')

    @staticmethod
    def get_or_create(steam_id, season_id):
        s = DotaSeasonStats.query.filter(and_(DotaSeasonStats.season_id==season_id, DotaSeasonStats.steam_id==steam_id)).all()
        if not s:
            s = DotaSeasonStats(steam_id=steam_id, season_id=season_id)
        else:
            s = s[0]
        return s

    def __repr__(self):
        return '{} ({})'.format(self.player.__repr__(), self.season.__repr__())

    def to_dict(self, extensive=False):
        d = {
            'id': self.id,
            'player': self.player.to_dict(extensive),
            'season_number': self.season.number
        }
        if extensive:
            d.update({
                'wins': self.wins,
                'loss': self.loss,
                'pts': self.pts,
                'streak': self.streak,
                'longest_streak': self.longest_winstreak 
            })
        return d
