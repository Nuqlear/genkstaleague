from sqlalchemy import and_
from sqlalchemy import case
from sqlalchemy import func

from gleague.models import PlayerMatchRating
from gleague.models import PlayerMatchStats
from gleague.models import SeasonStats


def get_pts_history(steam_id, season_id):
    pts_seq = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(
            and_(SeasonStats.season_id == season_id, SeasonStats.steam_id == steam_id)
        )
        .order_by(PlayerMatchStats.match_id)
        .values(PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)
    )
    pts_history = [[0, 1000]]
    for index, el in enumerate(pts_seq):
        pts_history.append([index + 1, el[0]])
    return pts_history


def get_heroes(steam_id, season_id=None):
    filters = SeasonStats.steam_id == steam_id
    if season_id is not None:
        filters = and_(filters, SeasonStats.season_id == season_id)
    query = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(filters)
        .with_entities(
            PlayerMatchStats.hero.label("hero"),
            func.count(PlayerMatchStats.id).label("played"),
            (
                100
                * func.sum(case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0))
                / func.count(PlayerMatchStats.id)
            ).label("winrate"),
            func.sum(case([
                (PlayerMatchStats.pts_diff > 0, 1),
                (PlayerMatchStats.pts_diff < 0, -1),
            ], else_=0)).label("win_loss"),
            func.sum(PlayerMatchStats.pts_diff).label("pts_diff"),
            (
                (func.avg(PlayerMatchStats.kills) + func.avg(PlayerMatchStats.assists))
                / func.avg(PlayerMatchStats.deaths + 1)
            ).label("kda"),
        )
        .group_by(PlayerMatchStats.hero)
    )
    return query


def get_rating_info(steam_id):
    rating_info = (
        PlayerMatchRating.query.join(PlayerMatchStats)
        .join(SeasonStats)
        .filter(SeasonStats.steam_id == steam_id)
        .with_entities(
            func.avg(PlayerMatchRating.rating), func.count(PlayerMatchRating.id)
        )
        .first()
    )
    avg_rating, rating_amount = rating_info
    avg_rating = avg_rating or 0
    return avg_rating, rating_amount
