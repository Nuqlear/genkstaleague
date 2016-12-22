from factory import Factory
from factory import Sequence
from factory import SubFactory
from factory.alchemy import SQLAlchemyModelFactory
from flask import current_app
from random import randrange

from gleague.core import db
from gleague import models
from gleague.utils.steam_api import get_dota2_heroes


class Factory(SQLAlchemyModelFactory):

    class Meta:
        sqlalchemy_session = db.session


class DotaSeasonFactory(Factory):
    
    class Meta:
        model = models.DotaSeason

    id = Sequence(lambda n: n)
    number = Sequence(lambda n: n)


class DotaSeasonStatsFactory(Factory):
    
    class Meta:
        model = models.DotaSeasonStats

    id = Sequence(lambda n: n)


class PlayerFactory(Factory):
    
    class Meta:
        model = models.Player

    steam_id = Sequence(lambda n: n)
    nickname = Sequence(lambda n: 'Player #%s' % n)


class DotaMatchFactory(Factory):

    class Meta:
        model = models.DotaMatch

    id = Sequence(lambda n: n)
    radiant_win = bool(randrange(0, 2))
    duration = randrange(1500, 3500)
    game_mode = 1
    start_time = randrange(1423, 1752)*100000

    @staticmethod
    def generate_with_all_stats(*args, **kwargs):
        match = DotaMatchFactory(*args, **kwargs)
        heroes = list(get_dota2_heroes(current_app.config['STEAM_API_KEY']).values())
        pms = []
        for slot in (list(range(5)) + list(range(128,133))):
            hero = heroes.pop(slot%len(heroes)).replace('npc_dota_hero_', '')
            player = PlayerFactory()
            season_stats = DotaSeasonStatsFactory(season_id=match.season_id, steam_id=player.steam_id)
            pts_diff = 20 if slot < 6 else -20
            if not match.radiant_win: 
                pts_diff = pts_diff*(-1)
            pms.append(DotaPlayerMatchStatsFactory(match_id=match.id, hero=hero, pts_diff=pts_diff, 
                season_stats_id=season_stats.id, player_slot=slot))
        match.players_stats = pms
        db.session.add(match)
        db.session.flush()
        return match

    @staticmethod
    def generate_batch_with_all_stats(amount, *args, **kwargs):
        return [DotaMatchFactory.generate_with_all_stats(*args, **kwargs) for i in range(amount)]


class DotaPlayerMatchStatsFactory(Factory):

    class Meta:
        model = models.DotaPlayerMatchStats

    id = Sequence(lambda n: n)
    old_pts = 1000
    kills = randrange(1, 25)
    deaths = randrange(1, 25)
    assists = randrange(1, 25)
    hero_damage = randrange(4, 25)*1000
    last_hits = randrange(1, 60)*4
    denies = randrange(1, 20)
    tower_damage = randrange(1, 25)*100
    hero_healing = randrange(1, 25)*100
    level = randrange(6, 26)


class DotaPlayerMatchRatingFactory(Factory):

    class Meta:
        model = models.DotaPlayerMatchRating

    id = Sequence(lambda n: n)
    rating = randrange(1, 6)
