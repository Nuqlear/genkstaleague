import json
import operator
import os
from functools import reduce
from unittest import mock

from gleague.api import create_app
from tests import GleagueAppTestCase
from tests.factories import MatchFactory
from tests.factories import PlayerMatchRatingFactory
from tests.factories import PlayerFactory


class GleagueApiTestCase(GleagueAppTestCase):

    matches_url = '/matches/'

    @classmethod
    def _create_app(cls):
        return create_app('gleague_api_tests')

    def setUp(self):
        super(GleagueApiTestCase, self).setUp()
        self.patches = [
            mock.patch('gleague.core.db.session.commit', side_effect=None), 
            mock.patch('gleague.core.db.session.remove', side_effect=None)
        ]
        for patch in self.patches:
            patch.start()

    def tearDown(self):
        super(GleagueApiTestCase, self).tearDown()
        for patch in self.patches:
            patch.stop()

    def add_match(self, json_match):
        return self.jpost(self.matches_url, data=json_match)

    def get_match(self, match_id):
        return self.jget(self.matches_url + '%i/' % match_id)

    def get_matches(self, amount, offset):
        return self.jget(self.matches_url + '?amount=%s&offset=%s' % (amount, offset))

    def rate_player(self, match_id, player_match_stats_id, rating):
        return self.post(self.matches_url + '%i/ratings/%i?rating=%i' % (match_id, player_match_stats_id, rating))

    def get_ratings(self, match_id):
        return self.get(self.matches_url + '%i/ratings/' % (match_id))

    def test_add_match(self, *args):
        json_file_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'fixtures/test_create_match.json')
        user = PlayerFactory()
        self.set_user(user.steam_id)
        response = self.add_match(None)
        self.assertEqual(403, response.status_code)
        user = PlayerFactory(steam_id=self.app.config['ADMINS_STEAM_ID'][0])
        self.set_user(user.steam_id)
        response = self.add_match(None)
        self.assertEqual(400, response.status_code)
        # TODO: test DEMO

    def test_rate_player(self, *args):
        user = PlayerFactory()
        self.set_user(user.steam_id)
        response = self.rate_player(1, 0, 4)
        self.assertEqual(404, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        ps = m.players_stats[0]
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

    def test_get_ratings(self, *args):
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        players_id = [ps.season_stats.steam_id for ps in m.players_stats[1:10]]
        match_ratings = []
        ps = m.players_stats[0]
        for pl_id in players_id:
            match_ratings.append(PlayerMatchRatingFactory(rated_by_steam_id=pl_id, player_match_stats_id=ps.id))
        response = self.get_ratings(m.id)
        data = json.loads(response.data.decode())
        self.assertEqual(200, response.status_code)
        avg_rating = reduce(operator.add, [mr.rating for mr in match_ratings]) / len(match_ratings)
        player_rating = data['ratings'].pop(str(ps.id))
        self.assertEqual(avg_rating, player_rating['avg_rating'])
        for key in data['ratings']:
            self.assertEqual(None, data['ratings'][key]['avg_rating'])
