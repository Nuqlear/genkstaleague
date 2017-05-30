import bz2
from io import BytesIO
from urllib.request import urlopen

from gleague.api import create_app
from gleague.models import Match
from tests import GleagueAppTestCase


class GleagueDem2jsonTestCase(GleagueAppTestCase):

    replay_url = 'http://replay123.valve.net/570/3214622621_845489484.dem.bz2'

    @classmethod
    def _create_app(cls):
        return create_app('gleague_api_tests')

    def download_replay(self):
        response = urlopen(self.replay_url)
        data = response.read()
        data = BytesIO(bz2.decompress(data))
        data.seek(0)
        return data

    def test_create_match_from_replay(self):
        match = Match.create_from_replay_fs(self.download_replay())
        self.assertNotEqual(match, None)
        for field in ['radiant_win', 'duration', 'game_mode', 'start_time', 'season_id']:
            # TODO: these fields should be with nullable=False
            self.assertNotEqual(getattr(match, field), None)
        self.assertLength(10, match.players_stats)