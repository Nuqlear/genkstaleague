import json
import operator
import os
from random import randint
from functools import reduce
from unittest import mock

from gleague.frontend import create_app
from tests import GleagueAppTestCase
from tests.factories.dota import MatchFactory
from tests.factories.dota import PlayerMatchRatingFactory
from tests.factories.dota import PlayerFactory


class GleagueFrontendTestCase(GleagueAppTestCase):

    matches_url = '/matches/'

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

    def get_match(self, match_id):
        return self.get(self.matches_url + '%i' % match_id)

    def get_matches(self, page=1):
        return self.get(self.matches_url + '?page=%s' % page)

    def test_get_match(self, *args):
        # response = self.get_match(randint(0, 100))
        # self.assertEqual(404, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        response = self.get_match(m.id)
        self.assertEqual(200, response.status_code)

    def test_get_matches(self, *args):
        # response = self.get_matches()
        # self.assertEqual(404, response.status_code)
        m = MatchFactory.generate_with_all_stats(season_id=self.season.id)
        response = self.get_matches()
        self.assertEqual(200, response.status_code)
        # response = self.get_matches(2)
        # self.assertEqual(404, response.status_code)
        matches_per_page = self.app.config['HISTORY_MATCHES_PER_PAGE']
        matches = MatchFactory.generate_batch_with_all_stats(matches_per_page, season_id=self.season.id)
        response = self.get_matches(2)
        self.assertEqual(200, response.status_code)
