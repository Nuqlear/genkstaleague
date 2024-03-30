import dataclasses as dc
from collections import namedtuple
from typing import List, Optional

from sqlalchemy import and_
from sqlalchemy import or_
from sqlalchemy import case
from sqlalchemy import desc
from sqlalchemy import func
from sqlalchemy import event
from sqlalchemy import select
from sqlalchemy.orm import aliased
from sqlalchemy.sql.expression import nullslast

from gleague.core import db, cache
from gleague.models import Match
from gleague.models import PlayerMatchStats
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models import Player
from gleague.models import Role
from gleague.models import CMPicksBans, TeamSeedPlayer
from gleague.heroes import get_human_readable_hero_name
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
    played = func.count(PlayerMatchStats.id).label("played")
    pts_diff = func.sum(PlayerMatchStats.pts_diff).label("pts_diff")
    winrate = (
        100 * func.sum(case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0)) / played
    ).label("winrate")
    win_loss = (
        func.sum(
            case(
                [
                    (PlayerMatchStats.pts_diff > 0, 1),
                    (PlayerMatchStats.pts_diff < 0, -1),
                ],
                else_=0,
            )
        )
    ).label("win_loss")
    return (
        PlayerMatchStats.query.join(SeasonStats)
        .join(Player)
        .filter(
            PlayerMatchStats.role == Role.core,
            PlayerMatchStats.position == Position.middle,
            SeasonStats.season_id == season_id,
        )
        .with_entities(
            Player.nickname,
            Player.steam_id,
            win_loss,
            pts_diff,
            played,
            winrate,
        )
        .group_by(Player.nickname, Player.steam_id, SeasonStats.id)
        .order_by(desc(pts_diff))
        .limit(3)
    ).all()


def get_most_powerful_supports(season_id):
    played = func.count(PlayerMatchStats.id).label("played")
    pts_diff = func.sum(PlayerMatchStats.pts_diff).label("pts_diff")
    winrate = (
        100 * func.sum(case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0)) / played
    ).label("winrate")
    win_loss = (
        func.sum(
            case(
                [
                    (PlayerMatchStats.pts_diff > 0, 1),
                    (PlayerMatchStats.pts_diff < 0, -1),
                ],
                else_=0,
            )
        )
    ).label("win_loss")
    return (
        PlayerMatchStats.query.join(SeasonStats)
        .join(Player)
        .filter(
            PlayerMatchStats.role == Role.support, SeasonStats.season_id == season_id
        )
        .with_entities(
            Player.nickname,
            Player.steam_id,
            win_loss,
            pts_diff,
            winrate,
            played,
        )
        .group_by(Player.nickname, Player.steam_id, SeasonStats.id)
        .order_by(desc(pts_diff))
        .limit(3)
    ).all()


side_winrates_nt = namedtuple("side_winrates_nt", ["dire", "radiant"])


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


def _get_most_iconic_duos(
    season_id,
    most_powerful=True,
    player_id=None,
    limit=3,
):
    ss1 = SeasonStats.__table__.alias()
    ss2 = SeasonStats.__table__.alias()
    pms1 = PlayerMatchStats.__table__.alias()
    pms2 = PlayerMatchStats.__table__.alias()
    query = (
        select(
            [
                ss1.c.steam_id.label("steam_id_1"),
                ss2.c.steam_id.label("steam_id_2"),
                func.count(pms1.c.id).label("games_played"),
                (
                    100
                    * func.sum(case([(pms1.c.pts_diff > 0, 1)], else_=0))
                    / func.count(pms1.c.id)
                ).label("winrate"),
                func.sum(
                    case(
                        [
                            (pms1.c.pts_diff > 0, 1),
                            (pms1.c.pts_diff < 0, -1),
                        ],
                        else_=0,
                    )
                ).label("win_loss"),
                func.sum(pms1.c.pts_diff).label("pts_diff_1"),
                func.sum(pms2.c.pts_diff).label("pts_diff_2"),
            ]
        )
        .select_from(
            pms1.join(
                pms2,
                and_(
                    pms2.c.match_id == pms1.c.match_id,
                    func.sign(pms2.c.pts_diff) == func.sign(pms1.c.pts_diff),
                    pms2.c.season_stats_id < pms1.c.season_stats_id,
                ),
            )
            .join(
                Match,
                and_(
                    Match.id == pms1.c.match_id,
                    Match.season_id == season_id,
                ),
            )
            .join(
                ss1,
                ss1.c.id == pms1.c.season_stats_id,
            )
            .join(
                ss2,
                ss2.c.id == pms2.c.season_stats_id,
            )
        )
        .group_by(ss1.c.steam_id, ss2.c.steam_id)
    )
    if player_id is not None:
        query = query.where(
            or_(
                ss1.c.steam_id == player_id,
                ss2.c.steam_id == player_id,
            )
        )
    pts_gain_cte = query.cte()

    p1 = aliased(Player)
    p2 = aliased(Player)

    query = db.session.query(
        p1,
        p2,
        pts_gain_cte.c.games_played,
        pts_gain_cte.c.winrate,
        pts_gain_cte.c.win_loss,
        pts_gain_cte.c.pts_diff_1,
        pts_gain_cte.c.pts_diff_2,
    ).select_from(
        pts_gain_cte.join(p1, pts_gain_cte.c.steam_id_1 == p1.steam_id).join(
            p2, pts_gain_cte.c.steam_id_2 == p2.steam_id
        ),
    )

    order_by_pts = False
    if order_by_pts is False:
        order_column = (pts_gain_cte.c.win_loss, pts_gain_cte.c.winrate)

    elif player_id is not None:
        order_column = case(
            [
                (pts_gain_cte.c.steam_id_1 == player_id, pts_gain_cte.c.pts_diff_1),
                (pts_gain_cte.c.steam_id_2 == player_id, pts_gain_cte.c.pts_diff_2),
            ]
        )

    if most_powerful:
        if order_by_pts and player_id is None:
            order_column = func.greatest(
                pts_gain_cte.c.pts_diff_1,
                pts_gain_cte.c.pts_diff_2,
            )
        if isinstance(order_column, tuple):
            query = query.order_by(*[desc(col) for col in order_column])
        else:
            query = query.order_by(order_column.desc())
    else:
        if order_by_pts and player_id is None:
            order_column = func.least(
                pts_gain_cte.c.pts_diff_1,
                pts_gain_cte.c.pts_diff_2,
            )
        if isinstance(order_column, tuple):
            query = query.order_by(*order_column)
        else:
            query = query.order_by(order_column)

    query = query.limit(limit)
    return query.all()


duo_nt = namedtuple(
    "duo_nt",
    [
        "player1",
        "player2",
        "games_played",
        "winrate",
        "win_loss",
        "player_1_pts_diff",
        "player_2_pts_diff",
    ],
)


def get_most_powerful_duos(season_id, player_id=None):
    return [duo_nt(*row) for row in _get_most_iconic_duos(season_id, True, player_id)]


def get_most_powerless_duos(season_id, player_id=None):
    return [duo_nt(*row) for row in _get_most_iconic_duos(season_id, False, player_id)]


@dc.dataclass
class SignatureOpponent:
    player: Player
    games_played: int
    winrate: float
    win_loss: int
    pts_diff: int


def get_signature_opponents(
    season_id,
    player_id,
    limit=3,
    is_asc=True,
):
    ss1 = SeasonStats.__table__.alias()
    ss2 = SeasonStats.__table__.alias()
    pms1 = PlayerMatchStats.__table__.alias()
    pms2 = PlayerMatchStats.__table__.alias()
    query = (
        select(
            [
                case(
                    [
                        (ss1.c.steam_id == player_id, ss2.c.steam_id),
                    ],
                    else_=ss1.c.steam_id,
                ).label("steam_id"),
                func.count(pms1.c.id).label("games_played"),
                case(
                    [
                        (
                            ss1.c.steam_id == player_id,
                            func.sum(
                                case(
                                    [
                                        (pms1.c.pts_diff > 0, 1),
                                        (pms1.c.pts_diff < 0, -1),
                                    ],
                                    else_=0,
                                )
                            ),
                        )
                    ],
                    else_=func.sum(
                        case(
                            [
                                (pms2.c.pts_diff > 0, 1),
                                (pms2.c.pts_diff < 0, -1),
                            ],
                            else_=0,
                        )
                    ),
                ).label("win_loss"),
                (
                    100
                    * case(
                        [
                            (
                                ss1.c.steam_id == player_id,
                                func.sum(
                                    case(
                                        [
                                            (pms1.c.pts_diff > 0, 1),
                                        ],
                                        else_=0,
                                    )
                                ),
                            )
                        ],
                        else_=func.sum(
                            case(
                                [
                                    (pms2.c.pts_diff > 0, 1),
                                ],
                                else_=0,
                            )
                        ),
                    )
                    / func.count(pms1.c.id)
                ).label("winrate"),
                case(
                    [(ss1.c.steam_id == player_id, func.sum(pms1.c.pts_diff))],
                    else_=func.sum(pms2.c.pts_diff),
                ).label("pts_diff"),
            ]
        )
        .select_from(
            pms1.join(
                pms2,
                and_(
                    pms2.c.match_id == pms1.c.match_id,
                    func.sign(pms2.c.pts_diff) != func.sign(pms1.c.pts_diff),
                    pms2.c.season_stats_id < pms1.c.season_stats_id,
                ),
            )
            .join(
                Match,
                and_(
                    Match.id == pms1.c.match_id,
                    Match.season_id == season_id,
                ),
            )
            .join(
                ss1,
                ss1.c.id == pms1.c.season_stats_id,
            )
            .join(
                ss2,
                ss2.c.id == pms2.c.season_stats_id,
            )
        )
        .group_by(ss1.c.steam_id, ss2.c.steam_id)
    )
    query = query.where(
        or_(
            ss1.c.steam_id == player_id,
            ss2.c.steam_id == player_id,
        )
    )
    pts_gain_cte = query.cte()

    player = aliased(Player)

    query = db.session.query(
        player,
        pts_gain_cte.c.games_played,
        pts_gain_cte.c.winrate,
        pts_gain_cte.c.win_loss,
        pts_gain_cte.c.pts_diff,
    ).select_from(pts_gain_cte.join(player, pts_gain_cte.c.steam_id == player.steam_id))

    order_columns = (pts_gain_cte.c.win_loss, pts_gain_cte.c.winrate)
    if is_asc:
        query = query.order_by(*order_columns)
    else:
        query = query.order_by(*[desc(col) for col in order_columns])

    query = query.limit(limit)
    return [SignatureOpponent(*row) for row in query]


@dc.dataclass
class SeasonHero:
    hero_name: str
    hero_human_readable: str
    pick_count: int
    ban_count: int
    winrate: float
    kda: float
    pts_diff: int
    win_loss: int


def get_heroes(
    season_id: int,
    *,
    order_by: str = "pick_count",
    is_desc: bool = True,
    limit: int = 3,
) -> List[SeasonHero]:
    played_cte = query_played_heroes(season_id=season_id).cte()

    banned_cte = (
        CMPicksBans.query.join(
            Match,
            and_(
                Match.id == CMPicksBans.match_id,
                Match.season_id == season_id,
            ),
        )
        .with_entities(
            Match.season_id.label("season_id"),
            CMPicksBans.is_pick.label("is_pick"),
            CMPicksBans.hero.label("hero"),
            func.count(CMPicksBans.id).label("cnt"),
        )
        .group_by(
            Match.season_id,
            CMPicksBans.is_pick,
            CMPicksBans.hero,
        )
    ).cte()

    order = {
        "hero": played_cte.c.hero,
        "pts_diff": played_cte.c.pts_diff,
        "pick_count": played_cte.c.played,
        "winrate": played_cte.c.winrate,
        "win_loss": played_cte.c.win_loss,
        "kda": played_cte.c.kda,
        "ban_count": banned_cte.c.cnt,
    }[order_by]

    if is_desc:
        order = desc(order)

    if order_by == "ban_count":
        order = nullslast(order)

    query = (
        CMPicksBans.query.join(
            Match,
            and_(
                Match.id == CMPicksBans.match_id,
                Match.season_id == season_id,
            ),
        )
        .outerjoin(
            banned_cte,
            and_(
                banned_cte.c.hero == CMPicksBans.hero,
                banned_cte.c.is_pick.is_(False),
            ),
        )
        .join(
            played_cte,
            func.concat("npc_dota_hero_", played_cte.c.hero) == CMPicksBans.hero,
        )
        .with_entities(
            CMPicksBans.hero,
            played_cte.c.played.label("pick_count"),
            banned_cte.c.cnt.label("ban_count"),
            played_cte.c.kda,
            played_cte.c.winrate,
            played_cte.c.win_loss,
            played_cte.c.pts_diff,
        )
        .order_by(order)
        .distinct()
        .limit(limit)
    )

    items = []
    for row in query:
        hero_name = row.hero.replace("npc_dota_hero_", "")
        items.append(
            SeasonHero(
                hero_name=hero_name,
                hero_human_readable=get_human_readable_hero_name(hero_name),
                pick_count=row.pick_count or 0,
                ban_count=row.ban_count or 0,
                winrate=row.winrate,
                win_loss=row.win_loss,
                kda=row.kda,
                pts_diff=row.pts_diff,
            )
        )
    return items


def query_played_heroes(season_id):
    query = (
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
            func.sum(
                case(
                    [
                        (PlayerMatchStats.pts_diff > 0, 1),
                        (PlayerMatchStats.pts_diff < 0, -1),
                    ],
                    else_=0,
                )
            ).label("win_loss"),
            func.sum(PlayerMatchStats.pts_diff).label("pts_diff"),
            (
                (func.avg(PlayerMatchStats.kills) + func.avg(PlayerMatchStats.assists))
                / func.avg(PlayerMatchStats.deaths + 1)
            ).label("kda"),
        )
        .group_by(PlayerMatchStats.hero)
    )
    return query


def get_most_successful_drafters(season_id, is_desc=True):
    # order_by = "pts_diff"
    order_by = "win_loss"
    if is_desc:
        order_by = desc(order_by)
    query = (
        PlayerMatchStats.query.join(
            Match,
            and_(
                Match.id == PlayerMatchStats.match_id,
                Match.season_id == season_id,
                Match.cm_captains.isnot(None),
                Match.cm_captains.any(PlayerMatchStats.player_slot),
            ),
        )
        .join(
            SeasonStats,
            SeasonStats.id == PlayerMatchStats.season_stats_id,
        )
        .join(
            Player,
            Player.steam_id == SeasonStats.steam_id,
        )
        .with_entities(
            Player.steam_id,
            Player.nickname,
            func.count(PlayerMatchStats.id).label("played"),
            func.sum(PlayerMatchStats.pts_diff).label("pts_diff"),
            (
                100
                * func.sum(case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0))
                / func.count(PlayerMatchStats.id)
            ).label("winrate"),
            func.sum(
                case(
                    [
                        (PlayerMatchStats.pts_diff > 0, 1),
                        (PlayerMatchStats.pts_diff < 0, -1),
                    ],
                    else_=0,
                )
            ).label("win_loss"),
        )
        .group_by(
            Player.steam_id,
            Player.nickname,
        )
        .order_by(order_by)
        .limit(3)
    )
    return query.all()


def get_double_downs_stat(season_id: int, is_desc: bool, limit: int = 3):
    order_by = "double_down_diff"
    if is_desc == True:
        order_by = desc(order_by)
    query = (
        PlayerMatchStats.query.join(
            Match,
            Match.id == PlayerMatchStats.match_id,
        )
        .join(
            SeasonStats,
            and_(
                SeasonStats.id == PlayerMatchStats.season_stats_id,
                SeasonStats.season_id == season_id,
            ),
        )
        .join(
            Player,
            Player.steam_id == SeasonStats.steam_id,
        )
        .outerjoin(
            TeamSeedPlayer,
            and_(
                TeamSeedPlayer.seed_id == Match.team_seed_id,
                TeamSeedPlayer.steam_id == SeasonStats.steam_id,
            ),
        )
        .with_entities(
            SeasonStats.steam_id,
            Player.nickname,
            func.count(PlayerMatchStats.id).label("played"),
            func.sum(
                case(
                    [
                        (
                            and_(
                                TeamSeedPlayer.is_double_down.is_(True),
                                PlayerMatchStats.pts_diff > 0,
                            ),
                            1,
                        )
                    ],
                    else_=0,
                )
            ).label("double_down_wins"),
            func.sum(
                case(
                    [
                        (
                            and_(
                                TeamSeedPlayer.is_double_down.is_(True),
                                PlayerMatchStats.pts_diff < 0,
                            ),
                            1,
                        )
                    ],
                    else_=0,
                )
            ).label("double_down_losses"),
            func.sum(
                case(
                    [
                        (
                            and_(
                                TeamSeedPlayer.is_double_down.is_(True),
                                PlayerMatchStats.pts_diff > 0,
                            ),
                            1,
                        ),
                        (
                            and_(
                                TeamSeedPlayer.is_double_down.is_(True),
                                PlayerMatchStats.pts_diff < 0,
                            ),
                            -1,
                        ),
                    ],
                    else_=0,
                )
            ).label("double_down_diff"),
        )
        .group_by(
            SeasonStats.steam_id,
            Player.nickname,
        )
        .order_by(order_by)
        .limit(limit)
    )
    return query.all()


@dc.dataclass
class PlaystyleStats:
    winrate: float
    played: int
    win_loss: int
    pts_diff: int


@dc.dataclass
class Playstyle:
    support: Optional[PlaystyleStats]
    core: Optional[PlaystyleStats]
    midlane: Optional[PlaystyleStats]


def _get_role_query(season_id, player_id, role):
    query = (
        PlayerMatchStats.query.join(
            Match,
            and_(
                Match.id == PlayerMatchStats.match_id,
                PlayerMatchStats.role == role,
            ),
        )
        .join(
            SeasonStats,
            and_(
                SeasonStats.id == PlayerMatchStats.season_stats_id,
                SeasonStats.season_id == season_id,
                SeasonStats.steam_id == player_id,
            ),
        )
        .join(
            Player,
            Player.steam_id == SeasonStats.steam_id,
        )
        .with_entities(
            func.count(PlayerMatchStats.id).label("played"),
            func.sum(PlayerMatchStats.pts_diff).label("pts_diff"),
            (
                100
                * func.sum(case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0))
                / func.count(PlayerMatchStats.id)
            ).label("winrate"),
            (
                func.sum(
                    case(
                        [
                            (PlayerMatchStats.pts_diff > 0, 1),
                            (PlayerMatchStats.pts_diff < 0, -1),
                        ],
                        else_=0,
                    )
                )
            ).label("win_loss"),
        )
    )
    return query


def get_playstyle(season_id, player_id) -> Playstyle:
    support_query = _get_role_query(season_id, player_id, Role.support)
    core_query = _get_role_query(season_id, player_id, Role.core)
    midlane_query = core_query.filter(PlayerMatchStats.position == Position.middle)
    support = support_query.first()
    core = core_query.first()
    midlane = midlane_query.first()
    return Playstyle(
        support=PlaystyleStats(
            winrate=support.winrate,
            played=support.played,
            win_loss=support.win_loss,
            pts_diff=support.pts_diff,
        ) if support.played else None,
        core=PlaystyleStats(
            winrate=core.winrate,
            played=core.played,
            win_loss=core.win_loss,
            pts_diff=core.pts_diff,
        ) if core.played else None,
        midlane=PlaystyleStats(
            winrate=midlane.winrate,
            played=midlane.played,
            win_loss=midlane.win_loss,
            pts_diff=midlane.pts_diff,
        ) if midlane.played else None
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
            "most_picked_heroes": get_heroes(
                season_id, order_by="pick_count", is_desc=True
            ),
            "most_banned_heroes": get_heroes(
                season_id, order_by="ban_count", is_desc=True
            ),
            "most_successful_drafters": get_most_successful_drafters(season_id),
            "least_successful_drafters": get_most_successful_drafters(
                season_id, is_desc=False
            ),
            "double_down_masters": get_double_downs_stat(season_id, is_desc=True),
            "double_down_losers": get_double_downs_stat(season_id, is_desc=False),
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
