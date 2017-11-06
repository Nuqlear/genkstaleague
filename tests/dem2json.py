import bz2
import os
from io import BytesIO
from urllib.request import urlopen
from unittest import mock
from subprocess import Popen, PIPE

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

    @mock.patch('gleague.models.match.Popen')
    def test_create_match_from_replay(self, mocked_popen):

        def mocked_popen_fn(args, **kwargs):
            go_files = ('dem2json', 'heroes', 'matchdata')
            new_args = ['go', 'run'] + [
                os.path.join(
                    os.getcwd(), 'dem2json/src/dem2json/%s.go' % f
                ) for f in go_files
            ]
            new_args.append(args[-1])
            return Popen(new_args, stdout=PIPE)

        mocked_popen.side_effect = mocked_popen_fn
        match = Match.create_from_replay_fs(self.download_replay())
        self.assertNotEqual(match, None)
        for field in [
            'radiant_win', 'duration', 'game_mode', 'start_time', 'season_id'
        ]:
            # TODO: these fields should be with nullable=False
            self.assertNotEqual(getattr(match, field), None)
        self.assertLength(10, match.players_stats)
