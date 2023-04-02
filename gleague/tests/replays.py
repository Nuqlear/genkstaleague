import bz2
from io import BytesIO
from urllib.request import urlopen

from flask import current_app

from gleague.api import create_app
from gleague.replays import ReplayParserService
from gleague.replays import ReplayDataProcessor
from tests import GleagueAppTestCase


REPLAY_DATA = {
    "match_id": 4373263421,
    "game_mode": 1,
    "start_time": 1548787364,
    "end_time": 1548787364,
    "duration": 1648,
    "radiant_win": True,
    "players": [
        {
            "account_id": 98167706,
            "account_id_orig": 76561198058433434,
            "hero_id": 31,
            "hero_name": "npc_dota_hero_lich",
            "kills": 3,
            "deaths": 0,
            "assists": 15,
            "last_hits": 16,
            "denies": 1,
            "level": 13,
            "player_slot": 0,
            "gold_per_min": 226,
            "xp_per_min": 297,
            "hero_damage": 8503,
            "damage_taken": 3104,
            "tower_damage": 121,
            "observer_wards_placed": 9,
            "sentry_wards_placed": 11,
            "early_denies": 1,
            "early_last_hits": 6,
            "items": [
                "item_smoke_of_deceit",
                "item_urn_of_shadows",
                "item_magic_wand",
                "item_infused_raindrop",
                "",
                "item_boots",
            ],
            "movement": [],
        },
        {
            "account_id": 86751819,
            "account_id_orig": 76561198047017547,
            "hero_id": 1,
            "hero_name": "npc_dota_hero_antimage",
            "kills": 9,
            "deaths": 0,
            "assists": 1,
            "last_hits": 263,
            "denies": 30,
            "level": 20,
            "player_slot": 1,
            "gold_per_min": 628,
            "xp_per_min": 702,
            "hero_damage": 8835,
            "damage_taken": 5341,
            "tower_damage": 3252,
            "observer_wards_placed": 0,
            "sentry_wards_placed": 0,
            "early_denies": 26,
            "early_last_hits": 63,
            "items": [
                "item_wraith_band",
                "item_manta",
                "item_power_treads",
                "item_quelling_blade",
                "item_stout_shield",
                "item_bfury",
            ],
            "movement": [],
        },
        {
            "account_id": 298683250,
            "account_id_orig": 76561198258948978,
            "hero_id": 59,
            "hero_name": "npc_dota_hero_huskar",
            "kills": 9,
            "deaths": 2,
            "assists": 6,
            "last_hits": 126,
            "denies": 19,
            "level": 16,
            "player_slot": 2,
            "gold_per_min": 455,
            "xp_per_min": 439,
            "hero_damage": 11459,
            "damage_taken": 10424,
            "tower_damage": 3991,
            "observer_wards_placed": 0,
            "sentry_wards_placed": 0,
            "early_denies": 11,
            "early_last_hits": 36,
            "items": [
                "item_armlet",
                "item_power_treads",
                "item_bracer",
                "item_black_king_bar",
                "item_bracer",
                "",
            ],
            "movement": [],
        },
        {
            "account_id": 90180366,
            "account_id_orig": 76561198050446094,
            "hero_id": 18,
            "hero_name": "npc_dota_hero_sven",
            "kills": 1,
            "deaths": 2,
            "assists": 12,
            "last_hits": 87,
            "denies": 1,
            "level": 13,
            "player_slot": 3,
            "gold_per_min": 295,
            "xp_per_min": 296,
            "hero_damage": 4908,
            "damage_taken": 11068,
            "tower_damage": 315,
            "observer_wards_placed": 0,
            "sentry_wards_placed": 0,
            "early_denies": 1,
            "early_last_hits": 47,
            "items": [
                "item_bracer",
                "item_quelling_blade",
                "item_phase_boots",
                "item_magic_wand",
                "item_vanguard",
                "item_vladmir",
            ],
            "movement": [],
        },
        {
            "account_id": 35504297,
            "account_id_orig": 76561197995770025,
            "hero_id": 86,
            "hero_name": "npc_dota_hero_rubick",
            "kills": 3,
            "deaths": 1,
            "assists": 11,
            "last_hits": 18,
            "denies": 7,
            "level": 11,
            "player_slot": 4,
            "gold_per_min": 208,
            "xp_per_min": 243,
            "hero_damage": 5827,
            "damage_taken": 4146,
            "tower_damage": 175,
            "observer_wards_placed": 2,
            "sentry_wards_placed": 1,
            "early_denies": 5,
            "early_last_hits": 7,
            "items": [
                "item_staff_of_wizardry",
                "item_wind_lace",
                "",
                "item_blink",
                "item_magic_wand",
                "item_arcane_boots",
            ],
            "movement": [],
        },
        {
            "account_id": 73401082,
            "account_id_orig": 76561198033666810,
            "hero_id": 5,
            "hero_name": "npc_dota_hero_crystal_maiden",
            "kills": 1,
            "deaths": 7,
            "assists": 2,
            "last_hits": 8,
            "denies": 2,
            "level": 8,
            "player_slot": 128,
            "gold_per_min": 149,
            "xp_per_min": 153,
            "hero_damage": 4608,
            "damage_taken": 6127,
            "tower_damage": 0,
            "observer_wards_placed": 10,
            "sentry_wards_placed": 10,
            "early_denies": 1,
            "early_last_hits": 4,
            "items": [
                "item_ward_dispenser",
                "item_boots",
                "",
                "item_wind_lace",
                "item_smoke_of_deceit",
                "",
            ],
            "movement": [],
        },
        {
            "account_id": 412413765,
            "account_id_orig": 76561198372679493,
            "hero_id": 8,
            "hero_name": "npc_dota_hero_juggernaut",
            "kills": 2,
            "deaths": 3,
            "assists": 1,
            "last_hits": 162,
            "denies": 23,
            "level": 13,
            "player_slot": 129,
            "gold_per_min": 407,
            "xp_per_min": 319,
            "hero_damage": 8306,
            "damage_taken": 6342,
            "tower_damage": 2392,
            "observer_wards_placed": 0,
            "sentry_wards_placed": 0,
            "early_denies": 14,
            "early_last_hits": 56,
            "items": [
                "item_power_treads",
                "item_magic_wand",
                "item_manta",
                "item_quelling_blade",
                "item_wraith_band",
                "item_wraith_band",
            ],
            "movement": [],
        },
        {
            "account_id": 137855976,
            "account_id_orig": 76561198098121704,
            "hero_id": 55,
            "hero_name": "npc_dota_hero_dark_seer",
            "kills": 0,
            "deaths": 6,
            "assists": 1,
            "last_hits": 119,
            "denies": 0,
            "level": 13,
            "player_slot": 130,
            "gold_per_min": 277,
            "xp_per_min": 299,
            "hero_damage": 6454,
            "damage_taken": 11008,
            "tower_damage": 602,
            "observer_wards_placed": 0,
            "sentry_wards_placed": 0,
            "early_denies": 0,
            "early_last_hits": 44,
            "items": [
                "item_arcane_boots",
                "item_stout_shield",
                "item_magic_wand",
                "item_soul_ring",
                "item_headdress",
                "item_hood_of_defiance",
            ],
            "movement": [],
        },
        {
            "account_id": 84385735,
            "account_id_orig": 76561198044651463,
            "hero_id": 97,
            "hero_name": "npc_dota_hero_magnataur",
            "kills": 0,
            "deaths": 4,
            "assists": 3,
            "last_hits": 35,
            "denies": 3,
            "level": 10,
            "player_slot": 131,
            "gold_per_min": 160,
            "xp_per_min": 203,
            "hero_damage": 1708,
            "damage_taken": 7081,
            "tower_damage": 64,
            "observer_wards_placed": 0,
            "sentry_wards_placed": 0,
            "early_denies": 3,
            "early_last_hits": 12,
            "items": [
                "",
                "",
                "item_arcane_boots",
                "item_blink",
                "",
                "item_magic_wand",
            ],
            "movement": [],
        },
        {
            "account_id": 110819366,
            "account_id_orig": 76561198071085094,
            "hero_id": 47,
            "hero_name": "npc_dota_hero_viper",
            "kills": 2,
            "deaths": 5,
            "assists": 3,
            "last_hits": 105,
            "denies": 22,
            "level": 12,
            "player_slot": 132,
            "gold_per_min": 326,
            "xp_per_min": 286,
            "hero_damage": 13007,
            "damage_taken": 8974,
            "tower_damage": 649,
            "observer_wards_placed": 0,
            "sentry_wards_placed": 0,
            "early_denies": 17,
            "early_last_hits": 43,
            "items": [
                "item_wraith_band",
                "item_wraith_band",
                "item_wraith_band",
                "item_power_treads",
                "item_maelstrom",
                "item_ogre_axe",
            ],
            "movement": [],
        },
    ],
    "draft": {"captains": [0, 123], "picks_and_bans": None},
}


class TestReplayParserService(GleagueAppTestCase):
    replay_url = "http://replay137.valve.net/570/4373263421_1281369645.dem.bz2"

    @classmethod
    def _create_app(cls):
        return create_app("gleague_api_tests")

    def download_replay(self):
        response = urlopen(self.replay_url)
        data = response.read()
        data = BytesIO(bz2.decompress(data))
        data.seek(0)
        return data

    def test_when_parse_replay_then_ok(self):
        parser = ReplayParserService(current_app.config["REPLAY_PARSER_HOST"])
        data = parser.parse_replay(self.download_replay())
        for p in data["players"]:
            assert p.pop("movement") is not None
            p["movement"] = []
        assert data == REPLAY_DATA


class TestReplayDataProcessor(GleagueAppTestCase):
    @classmethod
    def _create_app(cls):
        return create_app("gleague_api_tests")

    def test_when_save_replay_data_then_match_created(self):
        base_pts_diff = 10
        processor = ReplayDataProcessor(base_pts_diff)
        match = processor.save_replay_data(REPLAY_DATA)
        self.assertNotEqual(match, None)

        assert match.radiant_win is REPLAY_DATA["radiant_win"]
        assert match.game_mode == REPLAY_DATA["game_mode"]
        assert match.duration == REPLAY_DATA["duration"]
        assert match.start_time == REPLAY_DATA["start_time"]
        assert match.season_id is not None
        self.assertLength(10, match.players_stats)
