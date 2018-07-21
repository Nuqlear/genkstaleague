import json

from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import and_
from sqlalchemy import desc

from gleague.models import Player
from gleague.models import PlayerMatchStats
from gleague.models import PlayerMatchRating
from gleague.models import Season
from gleague.models import Match
from gleague.models import SeasonStats
from gleague.cache import cached


players_bp = Blueprint("players", __name__)


def get_season_stats(current_season_id, player):
    stats = player.season_stats.all()
    if not stats or stats[0].season_id != current_season_id:
        return {"wins": 0, "losses": 0, "pts": 1000}
    else:
        return stats[0]


@players_bp.route("/<int:steam_id>/", methods=["GET"])
@players_bp.route("/<int:steam_id>/overview", methods=["GET"])
@cached([Match, PlayerMatchRating])
def overview(steam_id):
    player = Player.query.filter(Player.steam_id == steam_id).first()
    if not player:
        return abort(404)
    current_season_id = Season.current().id
    stats = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(SeasonStats.steam_id == steam_id)
        .order_by(desc(PlayerMatchStats.match_id))
        .limit(current_app.config["PLAYER_OVERVIEW_MATCHES_AMOUNT"])
    )
    pts_seq = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(
            and_(
                SeasonStats.season_id == current_season_id,
                SeasonStats.steam_id == steam_id,
            )
        )
        .order_by(PlayerMatchStats.match_id)
        .values(PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)
    )
    pts_history = [[0, 1000]]
    for index, el in enumerate(pts_seq):
        pts_history.append([index + 1, el[0]])
    avg_rating, rating_amount = p.get_rating_info()
    signature_heroes = (
        player.get_heroes(current_season_id).order_by(desc("played")).limit(3).all()
    )
    matches_stats = stats.all()
    season_stats = get_season_stats(current_season_id, p)
    return render_template(
        "/player/overview.html",
        player=player,
        season_stats=season_stats,
        avg_rating=avg_rating,
        rating_amount=rating_amount,
        signature_heroes=signature_heroes,
        matches_stats=matches_stats,
        pts_history=json.dumps(pts_history),
    )


@players_bp.route("/<int:steam_id>/matches", methods=["GET"])
@cached([Match, PlayerMatchRating])
def matches(steam_id):
    player = Player.query.get(steam_id)
    if not player:
        return abort(404)
    page = request.args.get("page", "1")
    if not page.isdigit():
        abort(400)
    page = int(page)
    current_season_id = Season.current().id
    matches_stats = (
        PlayerMatchStats.query.order_by(desc(PlayerMatchStats.match_id))
        .join(SeasonStats)
        .filter(SeasonStats.steam_id == steam_id)
    )
    template_context = {"player": player}
    hero_filter = request.args.get("hero", None)
    if hero_filter:
        template_context["hero_filter"] = hero_filter
        matches_stats = matches_stats.filter(PlayerMatchStats.hero == hero_filter)
    template_context["matches_stats"] = matches_stats.paginate(
        page, current_app.config["PLAYER_HISTORY_MATCHES_PER_PAGE"], True
    )
    template_context["avg_rating"], template_context[
        "rating_amount"
    ] = player.get_rating_info()
    template_context["season_stats"] = get_season_stats(current_season_id, p)
    return render_template("/player/matches.html", **template_context)


@players_bp.route("/<int:steam_id>/heroes", methods=["GET"])
@cached([Match, PlayerMatchRating])
def heroes(steam_id):
    player = Player.query.get(steam_id)
    if not player:
        return abort(404)
    sort_value = request.args.get("sort", "played")
    if sort_value not in ["hero", "played", "pts_diff", "winrate", "kda"]:
        sort_value = "played"
    order_by = sort_value
    is_desc = request.args.get("desc", "yes")
    if is_desc != "no":
        is_desc = "yes"
        order_by = desc(order_by)
    current_season_id = Season.current().id
    heroes_stats = player.get_heroes(current_season_id).order_by(order_by).all()
    template_context = {"player": player, "sort": sort_value, "desc": is_desc}
    template_context["avg_rating"], template_context[
        "rating_amount"
    ] = player.get_rating_info()
    template_context["heroes_stats"] = heroes_stats
    template_context["season_stats"] = get_season_stats(current_season_id, p)
    return render_template("/player/heroes.html", **template_context)
