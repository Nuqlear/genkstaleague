import socket

from flask import current_app
from sqlalchemy import BigInteger
from sqlalchemy import Column
from sqlalchemy import String
from sqlalchemy import and_
from sqlalchemy import case
from sqlalchemy import func
from sqlalchemy.orm import relationship

from gleague.core import db
from gleague.models.match import PlayerMatchStats
from gleague.models.season import Season
from gleague.models.season import SeasonStats
from gleague.utils.steam_api import get_steam_user_info


socket.setdefaulttimeout(120)


class Player(db.Model):
    __tablename__ = 'player'

    steam_id = Column(BigInteger, primary_key=True)
    nickname = Column(String(80))
    avatar = Column(String(255))
    avatar_medium = Column(String(255))
    season_stats = relationship(
        'SeasonStats',
        lazy='dynamic',
        backref='player',
        order_by="desc(SeasonStats.season_id)"
    )

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
        p = Player.query.filter_by(steam_id=steam_id).first()
        if p is None:
            steamdata = get_steam_user_info(
                steam_id, current_app.config['STEAM_API_KEY']
            )
            if steamdata == {}:
                return None
            p = Player()
            p.steam_id = steam_id
            p.nickname = steamdata['personaname']
            p.avatar = steamdata['avatar']
            p.avatar_medium = steamdata['avatarmedium']
            db.session.add(p)
            db.session.flush()
        else:
            p.update_from_steam()
        cs = Season.current()
        last_season_stats = p.season_stats.first()
        if not last_season_stats or last_season_stats.season_id != cs.id:
            db.session.add(SeasonStats(season_id=cs.id, steam_id=p.steam_id))
        db.session.flush()
        return p

    def is_admin(self):
        return self.steam_id in current_app.config.get('ADMINS_STEAM_ID', [])

    def update_from_steam(self):
        steamdata = get_steam_user_info(
            self.steam_id, current_app.config['STEAM_API_KEY']
        )
        if steamdata == {}:
            return
        self.nickname = steamdata['personaname']
        self.avatar = steamdata['avatar']
        self.avatar_medium = steamdata['avatarmedium']

    def get_avg_rating(self):
        from gleague.models.match import PlayerMatchRating
        query = (
            PlayerMatchRating.query.join(PlayerMatchStats)
            .join(SeasonStats).filter(SeasonStats.steam_id == self.steam_id)
            .with_entities(
                func.avg(PlayerMatchRating.rating),
                func.count(PlayerMatchRating.id)
            ).all()
        )
        return query

    def get_heroes(self, current_season_id=None):
        filters = SeasonStats.steam_id == self.steam_id
        if current_season_id is not None:
            filters = and_(filters, SeasonStats.season_id == current_season_id)
        query = (
            PlayerMatchStats.query.join(SeasonStats).filter(filters)
            .with_entities(
                PlayerMatchStats.hero.label('hero'),
                func.count(PlayerMatchStats.id).label('played'),
                (
                    100 * func.sum(
                        case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0)
                    ) / func.count(PlayerMatchStats.id)
                ).label('winrate'),
                func.sum(PlayerMatchStats.pts_diff).label('pts_diff'),
                (
                    (
                        func.avg(PlayerMatchStats.kills) +
                        func.avg(PlayerMatchStats.assists)
                    ) /
                    func.avg(PlayerMatchStats.deaths + 1)
                ).label('kda')
        ).group_by(PlayerMatchStats.hero))
        return query
