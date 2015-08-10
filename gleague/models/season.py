import datetime

from sqlalchemy import Column, Integer, ForeignKey, BigInteger, DateTime, func, desc, and_
from sqlalchemy.orm import relationship

from ..core import db


class Season(db.Model):
    __tablename__ = 'season'
    id = Column(Integer, primary_key=True)
    number = Column(Integer, nullable=False, unique=True)
    started = Column(DateTime, default=datetime.datetime.now)
    ended = Column(DateTime)
    season_stats = relationship('SeasonStats', lazy='dynamic', backref='season')
    matches = relationship('Match', lazy='dynamic', backref='season')


    def __init__(self, *args, **kwargs):
        if 'number' not in kwargs:
            x = db.session.query(func.max(Season.number)).first()[0] or 0
            kwargs['number'] = 1 + x
        super(Season, self).__init__(*args, **kwargs)


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
        cs = Season.query.order_by(desc(Season.number)).first()
        return cs

    @staticmethod
    def start_new():
        os = Season.current()
        ns = Season()
        os.ended = ns.started
        db.session.add(ns)
        db.session.add(os)
        db.session.flush()
        return ns


class SeasonStats(db.Model):
    __tablename__ = 'season_stats'
    
    id = Column(Integer, primary_key=True)
    season_id = Column(Integer, ForeignKey('season.id', onupdate="CASCADE", ondelete="CASCADE"), nullable=False)
    steam_id = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"), nullable=False)
    wins = Column(Integer, default=0, nullable=False)
    losses = Column(Integer, default=0, nullable=False)
    pts = Column(Integer, default=1000, nullable=False)
    longest_winstreak = Column(Integer, default=0, nullable=False)
    longest_losestreak = Column(Integer, default=0, nullable=False)
    streak = Column(Integer, default=0, nullable=False)
    player_matches_stats = relationship('PlayerMatchStats', lazy='dynamic', backref='season_stats')

    @staticmethod
    def get_or_create(steam_id, season_id):
        s = SeasonStats.query.filter(and_(SeasonStats.season_id==season_id, SeasonStats.steam_id==steam_id)).all()
        if not s:
            s = SeasonStats(steam_id=steam_id, season_id=season_id)
            db.session.add(s)
            db.session.flush()
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
