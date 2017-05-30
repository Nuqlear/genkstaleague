import json
import operator
import os
from random import randint
from functools import reduce
from unittest import mock

from gleague.frontend import create_app
from tests import GleagueAppTestCase
from tests.factories import MatchFactory
from tests.factories import PlayerMatchRatingFactory
from tests.factories import PlayerFactory
from tests.factories import SeasonFactory


class GleagueFrontendTestCase(GleagueAppTestCase):

    matches_url = '/matches/'
    players_url = '/players/'
    seasons_url = '/seasons/'

    @classmethod
    def _create_app(cls):
        return create_app('gleague_frontend_tests')

    def setUp(self):
        super(GleagueFrontendTestCase, self).setUp()
        self.patches = [
            mock.patch('gleague.core.db.session.commit', side_effect=None), 
            mock.patch('gleague.core.db.session.remove', side_effect=None)
        ]
        for patch in self.patches:
            patch.start()

    def tearDown(self):
        super(GleagueFrontendTestCase, self).tearDown()
        for patch in self.patches:
            patch.stop()

    def get_player_overview(self, steam_id):
        return self.get(self.players_url + '%i/overview' % steam_id)

    def get_player_matches(self, steam_id):
        return self.get(self.players_url + '%i/matches' % steam_id)

    def get_player_heroes(self, steam_id):
        return self.get(self.players_url + '%i/heroes' % steam_id)

    def get_match(self, match_id):
        return self.get(self.matches_url + '%i' % match_id)

    def get_matches(self, page=1):
        return self.get(self.matches_url + '?page=%s' % page)

    def get_season_records(self, season_id='current'):
        return self.get(self.seasons_url+ '%s/records' % season_id)

    def get_season_players(self, season_id='current'):
        return self.get(self.seasons_url+ '%s/players' % season_id)

    def get_season_heroes(self, season_id='current'):
        return self.get(self.seasons_url+ '%s/heroes' % season_id)

    def test_get_match(self, *args):
        response = self.get_match(randint(0, 100))
        self.assertEqual(404, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        response = self.get_match(m.id)
        self.assertEqual(200, response.status_code)

    def test_get_matches(self, *args):
        response = self.get_matches()
        self.assertEqual(200, response.status_code)
        response = self.get_matches(2)
        self.assertEqual(404, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        response = self.get_matches()
        self.assertEqual(200, response.status_code)
        response = self.get_matches(2)
        self.assertEqual(404, response.status_code)
        matches_per_page = self.app.config['HISTORY_MATCHES_PER_PAGE']
        matches = MatchFactory.generate_batch_with_all_stats(matches_per_page, season_id=self.season.id)
        response = self.get_matches(2)
        self.assertEqual(200, response.status_code)
        response = self.get_matches(3)
        self.assertEqual(404, response.status_code)

    def test_get_player_pages(self, *args):
        invalid_id = randint(0, 99)
        valid_id = 100
        user = PlayerFactory(steam_id=valid_id)
        for steam_id, expectable_status_code in [(invalid_id, 404), (valid_id, 200)]:            
            for response in [self.get_player_overview(steam_id),
                             self.get_player_matches(steam_id),
                             self.get_player_heroes(steam_id)]:
                self.assertEqual(expectable_status_code, response.status_code)

    def test_get_season_pages(self, *args):
        def test_season_pages(season_id):
            for response in [self.get_season_records(season_id),
                             self.get_season_heroes(season_id),
                             self.get_season_players(season_id)]:
                self.assertEqual(200, response.status_code)
        for season_number in [self.season.number, SeasonFactory().number, 'current']:
            test_season_pages(season_number)
