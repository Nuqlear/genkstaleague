import datetime

from sqlalchemy import Column, Integer, ForeignKey, BigInteger, DateTime, func, desc, and_
from sqlalchemy.orm import relationship

from ..core import db


class Season(db.Model):
    __tablename__ = 'season'
    id = Column(Integer, primary_key=True)
    number = Column(Integer, nullable=False, unique=True)
    started = Column(DateTime, default=datetime.datetime.utcnow)
    ended = Column(DateTime)
    season_stats = relationship('SeasonStats', lazy='dynamic', backref='season', order_by="desc(SeasonStats.season_id)")
    matches = relationship('Match', lazy='dynamic', backref='season')
    place_1 = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"))
    place_2 = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"))
    place_3 = Column(BigInteger, ForeignKey('player.steam_id', onupdate="CASCADE", ondelete="CASCADE"))
    place_1_player = db.relationship('Player', foreign_keys='Season.place_1',
                              backref=db.backref('place_1_seasons', lazy='dynamic'))
    place_2_player = db.relationship('Player', foreign_keys='Season.place_2',
                              backref=db.backref('place_2_seasons', lazy='dynamic'))
    place_3_player = db.relationship('Player', foreign_keys='Season.place_3',
                              backref=db.backref('place_3_seasons', lazy='dynamic'))


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

    def end(self, date=datetime.datetime.utcnow()):
        self.ended = date
        stats = SeasonStats.query.filter(and_(SeasonStats.season_id==self.id, (SeasonStats.wins+SeasonStats.losses)>current_app.config.get('SEASON_CALIBRATING_MATCHES_NUM', 0)))\
            .with_entities(SeasonStats.steam_id,SeasonStats.pts).order_by(desc(SeasonStats.pts)).limit(3).all()
        for s in stats:
            self.place_1 = stats[0][0]
            self.place_2 = stats[1][0]
            self.place_3 = stats[2][0]

    @staticmethod
    def start_new():
        os = Season.current()
        ns = Season()
        os.end()
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
