import os
import json
import mock

from gleague import models
from gleague.core import db
from . import GleagueApiTestCase


class MatchTestCase(GleagueApiTestCase):
    base_url = '/matches/'

    def add_match(self, match_json):
        self.jpost(self.base_url, data=match_json)

    @mock.patch('gleague.models.match.db.session.commit', side_effect=db.session.flush)
    def test_add_match(self, mocked):
        json_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'fixtures/test_create_match.json')
        _f = open(json_path).read()
        self.add_match(_f)
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

    def test_get_match(self):
        # TODO
        pass
            