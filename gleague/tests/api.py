import json
import operator
from functools import reduce

from gleague.api import create_app
from tests import GleagueAppTestCase
from tests.factories import MatchFactory
from tests.factories import PlayerMatchRatingFactory
from tests.factories import PlayerFactory


class GleagueApiTestCase(GleagueAppTestCase):

    matches_url = '/matches/'
    replay_url = 'http://replay123.valve.net/570/3214622621_845489484.dem.bz2'

    @classmethod
    def _create_app(cls):
        return create_app('gleague_api_tests')

    def add_match(self):
        return self.post(self.matches_url)

    def rate_player(self, match_id, player_match_stats_id, rating):
        return self.post(
            self.matches_url + '%i/ratings/%i?rating=%i' %
            (match_id, player_match_stats_id, rating)
        )

    def get_ratings(self, match_id):
        return self.get(self.matches_url + '%i/ratings/' % (match_id))

    def test_add_match_rights(self, *args):
        user = PlayerFactory()
        self.set_user(user.steam_id)
        response = self.add_match()
        self.assertEqual(403, response.status_code)
        user = PlayerFactory(is_admin=True)
        self.set_user(user.steam_id)
        response = self.add_match()
        self.assertEqual(400, response.status_code)

    def test_rate_player(self, *args):
        user = PlayerFactory()
        self.set_user(user.steam_id)
        response = self.rate_player(1, 0, 4)
        self.assertEqual(404, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        player_stats = m.players_stats[0]
        user_id = player_stats.season_stats.steam_id
        self.set_user(user_id)
        rating = 4
        response = self.rate_player(m.id, player_stats.id, rating)
        self.assertEqual(200, response.status_code)
        self.assertEqual(player_stats.player_match_ratings[0].rating, rating)
        self.assertEqual(
            user_id, player_stats.player_match_ratings[0].rated_by_steam_id
        )
        response = self.rate_player(m.id, player_stats.id, 6)
        self.assertEqual(406, response.status_code)
        response = self.rate_player(m.id, player_stats.id, 0)
        self.assertEqual(406, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        player_stats = m.players_stats[0]
        rating = 4
        response = self.rate_player(m.id, player_stats.id, rating)
        self.assertEqual(403, response.status_code)

    def test_get_ratings(self, *args):
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        players_id = [
            player_stats.season_stats.steam_id
            for player_stats in m.players_stats[1:10]
        ]
        match_ratings = []
        player_stats = m.players_stats[0]
        for player_id in players_id:
            match_ratings.append(
                PlayerMatchRatingFactory(
                    rated_by_steam_id=player_id,
                    player_match_stats_id=player_stats.id
                )
            )
        response = self.get_ratings(m.id)
        data = json.loads(response.data.decode())
        self.assertEqual(200, response.status_code)
        avg_rating = reduce(
            operator.add,
            [mr.rating for mr in match_ratings]
        ) / len(match_ratings)
        player_rating = data['ratings'].pop(str(player_stats.id))
        self.assertEqual(avg_rating, player_rating['avg_rating'])
        for key in data['ratings']:
            self.assertEqual(None, data['ratings'][key]['avg_rating'])
