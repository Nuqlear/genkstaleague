from unittest import mock

from gleague.api import create_app
from tests import GleagueAppTestCase


class GleagueApiTestCase(GleagueAppTestCase):
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
