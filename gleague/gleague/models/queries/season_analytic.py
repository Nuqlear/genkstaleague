from collections import namedtuple

from flask import request
from sqlalchemy import and_
from sqlalchemy import case
from sqlalchemy import desc
from sqlalchemy import func
from sqlalchemy import event

from gleague.core import db, cache
from gleague.models import Match
from gleague.models import PlayerMatchStats
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models import Player
from gleague.models import Role
from gleague.utils.position import Position


def get_longest_match(season_id):
    subq = (
        Match.query.join(Season)
        .filter(Season.id == season_id)
        .with_entities(func.max(Match.duration))
        .as_scalar()
    )
    return Match.query.filter(
        and_(Match.duration == subq, Match.season_id == season_id)
    ).first()


def get_shortest_match(season_id):
    subq = (
        Match.query.join(Season)
        .filter(Season.id == season_id)
        .with_entities(func.min(Match.duration))
        .as_scalar()
    )
    return Match.query.filter(
        and_(Match.duration == subq, Match.season_id == season_id)
    ).first()


in_season_player_records_nt = namedtuple(
    "in_season_player_records_nt", ["title", "player", "value"]
)


def get_in_season_records(season_id):
    records = []
    for agg_function, field_name, label in [
        (func.max, "longest_losestreak", "Longest losestreak"),
        (func.max, "longest_winstreak", "Longest winstreak"),
    ]:
        field = getattr(SeasonStats, field_name)
        subq = (
            SeasonStats.query.filter(SeasonStats.season_id == season_id)
            .with_entities(func.max(field))
            .as_scalar()
        )
        query = (
            db.session.query(SeasonStats)
            .filter(and_(SeasonStats.season_id == season_id, field == subq))
            .first()
        )
        if query:
            records.append(
                in_season_player_records_nt(
                    label, query.player, getattr(query, field_name)
                )
            )
    for agg_function, label in [(func.max, "Max pts ever"), (func.min, "Min pts ever")]:
        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == season_id)
            .with_entities(
                agg_function(PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)
            )
            .as_scalar()
        )
        query = (
            db.session.query(PlayerMatchStats)
            .join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == season_id,
                    (PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff) == subq,
                )
            )
            .order_by(PlayerMatchStats.id)
            .first()
        )
        if query:
            records.append(
                in_season_player_records_nt(
                    label, query.season_stats.player, query.old_pts + query.pts_diff
                )
            )
    return records


in_match_records_nt = namedtuple(
    "in_match_records_nt", ["match_id", "record_name", "player", "hero", "value"]
)


def _get_best_kda(season_id):
    subq = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(SeasonStats.season_id == season_id)
        .with_entities(
            func.max(
                (PlayerMatchStats.kills + PlayerMatchStats.assists)
                / (PlayerMatchStats.deaths + 1)
            )
        )
        .as_scalar()
    )
    max_kda_pms = (
        db.session.query(PlayerMatchStats)
        .join(SeasonStats)
        .filter(
            and_(
                SeasonStats.season_id == season_id,
                (
                    (PlayerMatchStats.kills + PlayerMatchStats.assists)
                    / (PlayerMatchStats.deaths + 1)
                    == subq
                ),
            )
        )
        .order_by(PlayerMatchStats.id)
        .first()
    )
    if max_kda_pms:
        return in_match_records_nt(
            max_kda_pms.match_id,
            "Best KDA",
            max_kda_pms.season_stats.player,
            max_kda_pms.hero,
            ((max_kda_pms.kills + max_kda_pms.assists) / (max_kda_pms.deaths + 1)),
        )


def get_in_match_records(season_id):
    records = [_get_best_kda(season_id)]
    for agg_function, field_name, label in [
        (func.max, "kills", "Max kills"),
        (func.max, "deaths", "Max deaths"),
        (func.max, "assists", "Max assists"),
        (func.max, "hero_damage", "Most hero damage"),
        (func.max, "last_hits", "Most last hits"),
        (func.max, "hero_healing", "Max hero healing"),
        (func.max, "xp_per_min", "Max XP per min"),
        (func.max, "gold_per_min", "Max gold per min"),
        (func.max, "tower_damage", "Most tower damage"),
        (func.max, "damage_taken", "Most damage taken"),
        (func.max, "observer_wards_placed", "Most observer wards placed"),
        (func.max, "sentry_wards_placed", "Most sentry wards placed"),
        (func.max, "early_last_hits", "Max Last Hits at 10 minutes"),
        (func.max, "early_denies", "Max Denies at 10 minutes"),
    ]:
        field = getattr(PlayerMatchStats, field_name)
        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == season_id)
            .with_entities(agg_function(field))
            .as_scalar()
        )
        query = (
            db.session.query(PlayerMatchStats)
            .join(SeasonStats)
            .filter(and_(SeasonStats.season_id == season_id, field == subq))
            .order_by(PlayerMatchStats.id)
            .first()
        )
        if query:
            records.append(
                in_match_records_nt(
                    query.match_id,
                    label,
                    query.season_stats.player,
                    query.hero,
                    getattr(query, field_name),
                )
            )
    return records


def get_avg_match_duration(season_id):
    return (
        Match.query.join(Season)
        .filter(Season.id == season_id)
        .with_entities(func.avg(Match.duration))
        .scalar()
    )


def get_most_powerful_midlaners(season_id):
    pts_diff = func.sum(PlayerMatchStats.pts_diff).label("pts_diff")
    return (
        PlayerMatchStats.query.join(SeasonStats)
        .join(Player)
        .filter(
            PlayerMatchStats.role == Role.core,
            PlayerMatchStats.position == Position.middle,
            SeasonStats.season_id == season_id,
        )
        .with_entities(Player.nickname, Player.steam_id, pts_diff)
        .group_by(Player.nickname, Player.steam_id, SeasonStats.id)
        .order_by(desc(pts_diff))
        .limit(3)
    ).all()


def get_most_powerful_supports(season_id):
    pts_diff = func.sum(PlayerMatchStats.pts_diff).label("pts_diff")
    return (
        PlayerMatchStats.query.join(SeasonStats)
        .join(Player)
        .filter(
            PlayerMatchStats.role == Role.support, SeasonStats.season_id == season_id
        )
        .with_entities(Player.nickname, Player.steam_id, pts_diff)
        .group_by(Player.nickname, Player.steam_id, SeasonStats.id)
        .order_by(desc(pts_diff))
        .limit(3)
    ).all()


side_winrates_nt = namedtuple("side_winrates_nt", ["radiant", "dire"])


def get_side_winrates(season_id):
    return side_winrates_nt(
        *(
            Match.query.join(Season)
            .filter(Season.id == season_id)
            .with_entities(
                *[
                    (
                        100
                        * func.sum(
                            case([(Match.radiant_win.is_(radiant_win), 1)], else_=0)
                        )
                        / func.count(Match.id)
                    )
                    for radiant_win in [False, True]
                ]
            )
            .first()
        )
    )


def _get_most_iconic_duos(season_id, most_powerful=True, limit=3):
    duos_result = db.session.execute(
        """
        SELECT p1.nickname, p2.nickname, result.sum FROM (
            SELECT ss1.steam_id as steam_id_1, ss2.steam_id as steam_id_2,
            (
                SELECT SUM(pms1.pts_diff)
                FROM player_match_stats pms1
                WHERE pms1.season_stats_id=ss1.id
                AND EXISTS(
                    SELECT * FROM player_match_stats pms2
                    WHERE pms2.match_id=pms1.match_id AND pms2.pts_diff=pms1.pts_diff
                    AND pms2.season_stats_id=ss2.id
                )
            ) as sum
            FROM season_stats ss1
            JOIN season_stats ss2 ON ss1.steam_id < ss2.steam_id
            AND ss1.season_id=ss2.season_id AND ss1.season_id=:season_id
            ORDER BY sum {order_direction_desc}
        ) result
        JOIN player p1 ON p1.steam_id=result.steam_id_1
        JOIN player p2 ON p2.steam_id=result.steam_id_2
        WHERE result.sum is not NULL
        LIMIT :limit;
        """.format(
            order_direction_desc=("DESC" if most_powerful else "ASC")
        ),
        {"season_id": season_id, "limit": limit},
    )
    return duos_result.fetchall()


duo_nt = namedtuple("duo_nt", ["player1", "player2", "pts_diff"])


def get_most_powerful_duos(season_id):
    return [duo_nt(*row) for row in _get_most_iconic_duos(season_id)]


def get_most_powerless_duos(season_id):
    return [duo_nt(*row) for row in _get_most_iconic_duos(season_id, False)]


def get_player_heroes(season_id, order_by):
    if order_by not in ["hero", "played", "pts_diff", "winrate", "kda"]:
        order_by = "played"
    order_by = order_by
    is_desc = request.args.get("desc", "yes")
    if is_desc != "no":
        is_desc = "yes"
        order_by = desc(order_by)
    return (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(SeasonStats.season_id == season_id)
        .with_entities(
            PlayerMatchStats.hero,
            func.count(PlayerMatchStats.id).label("played"),
            (
                100
                * func.sum(case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0))
                / func.count(PlayerMatchStats.id)
            ).label("winrate"),
            func.sum(PlayerMatchStats.pts_diff).label("pts_diff"),
            (
                (func.avg(PlayerMatchStats.kills) + func.avg(PlayerMatchStats.assists))
                / func.avg(PlayerMatchStats.deaths + 1)
            ).label("kda"),
        )
        .group_by(PlayerMatchStats.hero)
        .order_by(order_by)
        .all()
    )


@cache.cache_on_arguments("week")
def get_all_season_records(season_id):
    longest_match = get_longest_match(season_id)
    if longest_match:
        return {
            "longest_match": longest_match,
            "shortest_match": get_shortest_match(season_id),
            "in_season_player_records": get_in_season_records(season_id),
            "in_match_records": get_in_match_records(season_id),
            "avg_match_duration": get_avg_match_duration(season_id),
            "most_powerful_sups": get_most_powerful_supports(season_id),
            "most_powerful_midlaners": get_most_powerful_midlaners(season_id),
            "side_winrates": get_side_winrates(season_id),
            "powerful_duos": get_most_powerful_duos(season_id),
            "powerless_duos": get_most_powerless_duos(season_id),
        }
    return {}


@event.listens_for(Match, "after_update", propagate=True)
@event.listens_for(Match, "after_insert", propagate=True)
def clear_cache_after_matches_update(mapper, connection, target):
    get_all_season_records.invalidate(target.season_id)


@event.listens_for(Season, "after_insert", propagate=True)
def clear_cache_after_new_season(mapper, connection, target):
    previous_season_number = (
        Season.query.filter(Season.number < target.number)
        .with_entities(func.max(Season.number))
        .as_scalar()
    )
    previous_season = Season.query.filter(
        Season.number == previous_season_number
    ).first()
    if previous_season:
        get_all_season_records.invalidate(previous_season.id)
