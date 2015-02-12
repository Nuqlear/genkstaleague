import os
import json
import mock

from gleague.core import db
from gleague import models
from . import GleagueApiTestCase
from ..factories import PlayerMatchStatsFactory, MatchFactory, SeasonFactory, PlayerFactory, PlayerMatchRatingFactory


class MatchTestCase(GleagueApiTestCase):
    base_url = '/matches/'
    maxDiff = None

    def _create_fixtures(self):
        self.season = SeasonFactory()

    def add_match(self, match_json):
        return self.jpost(self.base_url, data=match_json)

    def get_match(self, match_id):
        return self.jget(self.base_url + '%i/' % match_id)

    def get_matches(self, amount, offset):
        return self.jget(self.base_url + '?amount=%s&offset=%s' % (amount, offset))

    def rate_player(self, match_id, player_match_stats_id, rating):
        return self.post(self.base_url + '%i/ratings/%i/?rating=%i' % (match_id, player_match_stats_id, rating))

    def get_ratings(self, match_id):
        return self.get(self.base_url + '%i/ratings/' % (match_id))

    def test_add_match(self):
        c = db.session.commit
        db.session.commit = mock.Mock(side_effect=db.session.flush)
        json_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'fixtures/test_create_match.json')
        _f = open(json_path).read()

        user = PlayerFactory()
        self.set_user(user.steam_id)
        response = self.add_match(_f)
        self.assertEqual(403, response.status_code)

        user = PlayerFactory(steam_id=self.app.config['ADMINS_STEAM_ID'][0])
        self.set_user(user.steam_id)
        response = self.add_match(None)
        self.assertEqual(400, response.status_code)
        response = self.add_match(_f)
        self.assertEqual(201, response.status_code)
        data = json.loads(_f)['result']
        match = models.Match.query.first()
        self.assertEqual(match.id, data['match_id'])
        self.assertEqual(match.start_time, data['start_time'])
        self.assertEqual(match.duration, data['duration'])
        self.assertEqual(match.radiant_win, data['radiant_win'])
        self.assertEqual(match.game_mode, data['game_mode'])
        players_data = sorted(data['players'], key=lambda e: e['player_slot'])
        for index in range(match.players_stats.count(models.PlayerMatchStats.id)):
            player_stats = match.players_stats[index]
            player_data = players_data[index]
            self.assertEqual(player_stats.player.steam_id, player_data['account_id'])
            self.assertEqual(player_stats.old_pts, models.SeasonStats.pts.default)
            self.assertEqual(player_stats.pts_diff, models.Match.base_pts_diff)
            self.assertEqual(player_stats.season_stats.pts, player_stats.old_pts + player_stats.pts_diff)
            self.assertEqual(player_stats.season_stats.wins, 1*(player_stats.pts_diff>0))
            self.assertEqual(player_stats.season_stats.losses, 1*(player_stats.pts_diff<0))
            self.assertEqual(player_stats.season_stats.streak, player_stats.season_stats.longest_streak)
            self.assertEqual(player_stats.kills, player_data['kills'])
            self.assertEqual(player_stats.deaths, player_data['deaths'])
            self.assertEqual(player_stats.assists, player_data['assists'])
            self.assertEqual(player_stats.hero_damage, player_data['hero_damage'])
            self.assertEqual(player_stats.last_hits, player_data['last_hits'])
            self.assertEqual(player_stats.player_slot, player_data['player_slot'])
            self.assertEqual(player_stats.denies, player_data['denies'])
            self.assertEqual(player_stats.tower_damage, player_data['tower_damage'])
            self.assertEqual(player_stats.hero, player_data['hero'])
            self.assertEqual(player_stats.hero_healing, player_data['hero_healing'])
            self.assertEqual(player_stats.level, player_data['level'])
        db.session.commit = c

    def test_get_match(self):
        response = self.get_match(1)
        self.assertEqual(404, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        response = self.get_match(m.id)
        self.assertEqual(200, response.status_code)
        data = json.loads(response.data.decode())
        self.assertEqual(data, m.to_dict())
            
    def test_get_matches(self):
        matches = MatchFactory.generate_batch_with_all_stats(10, season_id=self.season.id)

        response = self.get_matches('test', 0)
        self.assertEqual(406, response.status_code)

        response = self.get_matches(4, 'test')
        self.assertEqual(406, response.status_code)

        response = self.get_matches(4, 0)
        data = json.loads(response.data.decode())
        self.assertEqual(data, {'matches':[m.to_dict(False) for m in matches[:4]]})
        self.assertEqual(200, response.status_code)

        response = self.get_matches(3, 2)
        data = json.loads(response.data.decode())
        self.assertEqual(data, {'matches':[m.to_dict(False) for m in matches[6:9]]})
        self.assertEqual(200, response.status_code)

    def test_rate_player(self):
        c = db.session.commit
        db.session.commit = mock.Mock(side_effect=db.session.flush)

        user = PlayerFactory()
        self.set_user(user.steam_id)
        response = self.rate_player(1, 0, 4)
        self.assertEqual(404, response.status_code)

        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        ps = m.players_stats[0]
        print(type(ps.season_stats))
        print(dir(ps.season_stats))
        user_id = ps.season_stats.steam_id
        self.set_user(user_id)
        rating = 4
        response = self.rate_player(m.id, ps.id, rating)
        self.assertEqual(200, response.status_code)
        self.assertEqual(ps.player_match_ratings[0].rating, rating)
        self.assertEqual(user_id, ps.player_match_ratings[0].rated_by_steam_id)

        response = self.rate_player(m.id, ps.id, 6)
        self.assertEqual(406, response.status_code)

        response = self.rate_player(m.id, ps.id, 0)
        self.assertEqual(406, response.status_code)

        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        ps = m.players_stats[0]
        rating = 4
        response = self.rate_player(m.id, ps.id, rating)
        self.assertEqual(403, response.status_code)
        db.session.commit = c

    def test_get_ratings(self):
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        ps = m.players_stats[0]
        players_id = [ps.season_stats.steam_id for ps in m.players_stats[1:10]]
        match_ratings = []
        for pl_id in players_id:
            match_ratings.append(PlayerMatchRatingFactory(rated_by_steam_id=pl_id, player_match_stats_id=ps.id))

        response = self.get_ratings(m.id)
        data = json.loads(response.data.decode())

        self.set_user(m.players_stats[5].season_stats.steam_id)
        response = self.get_ratings(m.id)
        data = json.loads(response.data.decode())
