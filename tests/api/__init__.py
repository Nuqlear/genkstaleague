from gleague.api import create_app

from .. import GleagueAppTestCase


class GleagueApiTestCase(GleagueAppTestCase):
    @classmethod
    def _create_app(cls):
        return create_app('gleague.config.gleague_api_tests')
