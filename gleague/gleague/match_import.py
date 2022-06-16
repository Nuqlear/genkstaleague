import requests

from gleague.core import db
from gleague.models import Match
from gleague.models import Season
from gleague.models import CMPicksBans
from gleague.models import PlayerMatchStats
from gleague.models import Player
from gleague.models import SeasonStats
from gleague.models import Role
from gleague.models import PlayerMatchItem
from gleague.utils.position import detect_position


def _set_match_players_pts(base_pts_diff, match):
    pts = dict(radiant=0, dire=0)
    pts_deviation = int(abs(pts["radiant"] - pts["dire"]) / 20)
    if pts_deviation > base_pts_diff - 5:
        pts_deviation = base_pts_diff - 5
    pts_diff = base_pts_diff
    if (pts["dire"] > pts["radiant"]) == match.radiant_win:
        pts_diff += pts_deviation
    else:
        pts_diff -= pts_deviation
    for stats in match.players_stats:
        if stats.is_winner():
            stats.pts_diff = pts_diff
        else:
            stats.pts_diff = -pts_diff
        stats.season_stats.pts += stats.pts_diff


def _set_match_players_streaks(match):
    for stats in match.players_stats:
        season_stats = stats.season_stats
        if stats.pts_diff > 0:
            season_stats.wins += 1
            if season_stats.streak > 0:
                season_stats.streak += 1
            else:
                season_stats.streak = 1
            if season_stats.streak > season_stats.longest_winstreak:
                season_stats.longest_winstreak = season_stats.streak
        else:
            if season_stats.streak > 0:
                season_stats.streak = -1
            else:
                season_stats.streak -= 1
            season_stats.losses += 1
            if season_stats.streak < -(season_stats.longest_losestreak):
                season_stats.longest_losestreak = -(season_stats.streak)


def _set_match_players_roles(match):
    sort_by_lh = lambda s: s.early_last_hits  # noqa
    radiant_players = sorted(
        filter(lambda s: s.player_slot < 5, match.players_stats), key=sort_by_lh
    )
    dire_players = sorted(
        filter(lambda s: s.player_slot > 5, match.players_stats), key=sort_by_lh
    )
    supports_number = 2
    supports = radiant_players[:supports_number] + dire_players[:supports_number]
    cores = radiant_players[supports_number:] + dire_players[supports_number:]
    for sup in supports:
        sup.role = Role.support
    for core in cores:
        core.role = Role.core


def create_match_from_data(match_data, base_pts_diff):
    match = Match()
    match.season_id = Season.current().id
    match.id = match_data["match_id"]
    match.radiant_win = bool(match_data["radiant_win"])
    for key in ("duration", "game_mode", "start_time"):
        setattr(match, key, match_data[key])
    db.session.add(match)
    if match.game_mode == 2:
        match.cm_captains = match_data["draft"]["captains"]
        for pick_ban_data in match_data["draft"]["picks_and_bans"]:
            db.session.add(
                CMPicksBans(
                    is_pick=pick_ban_data["is_pick"],
                    is_radiant=pick_ban_data["is_radiant"],
                    hero=pick_ban_data["hero"],
                    match_id=match.id,
                )
            )
    for player_data in match_data["players"]:
        player_stats = PlayerMatchStats()
        account_id = "765" + str(player_data["account_id"] + 61197960265728)
        player = Player.get_or_create(account_id)
        if player is None:
            db.session.rollback()
            return None
        db.session.flush()
        season_stats = SeasonStats.get_or_create(account_id, match.season_id)
        player_stats.pts_diff = 20
        player_stats.season_stats_id = season_stats.id
        for key in (
            "kills",
            "assists",
            "level",
            "deaths",
            "hero_damage",
            "last_hits",
            "player_slot",
            "denies",
            "tower_damage",
            "damage_taken",
            "xp_per_min",
            "gold_per_min",
            "movement",
            "early_denies",
            "early_last_hits",
            "observer_wards_placed",
            "sentry_wards_placed",
        ):
            setattr(player_stats, key, player_data[key])
        player_stats.hero = player_data["hero_name"].replace("npc_dota_hero_", "")
        player_stats.position = detect_position(
            list([[pos["x"], pos["y"]] for pos in player_stats.movement])
        )
        for item in player_data["items"]:
            if item:
                db.session.add(
                    PlayerMatchItem(name=item, player_match_stats=player_stats)
                )
        player_stats.match_id = match.id
        db.session.add(player_stats)
        db.session.add(season_stats)
        player_stats.old_pts = season_stats.pts
    _set_match_players_pts(base_pts_diff, match)
    _set_match_players_roles(match)
    _set_match_players_streaks(match)
    db.session.add(match)
    db.session.flush()
    return match


class Dem2jsonError(Exception):
    pass


def create_match_from_replay(replay_io, base_pts_diff):
    resp = requests.post(
        url="http://dem2json:5222",
        data=replay_io.read(),
        headers={"Content-Type": "application/octet-stream"},
    )

    if resp.status_code == 200:
        match_data = resp.json()["result"]
        return create_match_from_data(match_data, base_pts_diff)

    if resp.status_code == 400:
        error = resp.json()["error"]
        raise Dem2jsonError(error)

    raise Dem2jsonError("Internal Server Error")
