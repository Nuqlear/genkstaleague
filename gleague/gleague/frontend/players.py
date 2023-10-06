import json

from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import desc

from gleague.models import Player
from gleague.models import PlayerMatchStats
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models.queries import player_analytic
from gleague.models.queries.season_analytic import get_most_powerful_duos
from gleague.models.queries.season_analytic import get_most_powerless_duos


players_bp = Blueprint("players", __name__)


def get_season_stats(current_season_id, player):
    stats = player.season_stats.all()
    if not stats or stats[0].season_id != current_season_id:
        return {"wins": 0, "losses": 0, "pts": 1000}
    else:
        return stats[0]


@players_bp.route("/<int:steam_id>/", methods=["GET"])
@players_bp.route("/<int:steam_id>/overview", methods=["GET"])
def overview(steam_id):
    player = Player.query.filter(Player.steam_id == steam_id).first()
    if not player:
        return abort(404)
    current_season_id = Season.current().id
    matches_stats = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(SeasonStats.steam_id == steam_id)
        .order_by(desc(PlayerMatchStats.match_id))
        .limit(current_app.config["PLAYER_OVERVIEW_MATCHES_AMOUNT"])
        .all()
    )
    signature_heroes = (
        player_analytic.get_heroes(player.steam_id, current_season_id)
        .order_by(desc("played"))
        .limit(3)
        .all()
    )
    avg_rating, rating_amount = player_analytic.get_rating_info(player.steam_id)
    best_team_mates = get_most_powerful_duos(
        current_season_id,
        steam_id,
    )
    worst_team_mates = get_most_powerless_duos(
        current_season_id,
        steam_id,
    )
    return render_template(
        "/player/overview.html",
        player=player,
        season_stats=get_season_stats(current_season_id, player),
        avg_rating=avg_rating,
        rating_amount=rating_amount,
        signature_heroes=signature_heroes,
        matches_stats=matches_stats,
        best_team_mates=best_team_mates,
        worst_team_mates=worst_team_mates,
        pts_history=json.dumps(
            player_analytic.get_pts_history(steam_id, current_season_id)
        ),
    )


@players_bp.route("/<int:steam_id>/matches", methods=["GET"])
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
    template_context["season_stats"] = get_season_stats(current_season_id, player)
    return render_template("/player/matches.html", **template_context)


@players_bp.route("/<int:steam_id>/heroes", methods=["GET"])
def heroes(steam_id):
    player = Player.query.get(steam_id)
    if not player:
        return abort(404)
    sort = request.args.get("sort", "played")
    if sort not in ["hero", "played", "pts_diff", "winrate", "kda"]:
        sort = "played"
    order_by = sort
    is_desc = request.args.get("desc", "yes")
    if is_desc != "no":
        is_desc = "yes"
        order_by = desc(order_by)
    current_season_id = Season.current().id
    heroes_stats = (
        player_analytic.get_heroes(player.steam_id, current_season_id)
        .order_by(order_by)
        .all()
    )
    template_context = {
        "player": player,
        "sort": sort,
        "desc": is_desc,
        "heroes_stats": heroes_stats,
        "season_stats": get_season_stats(current_season_id, player),
    }
    rating_info = player_analytic.get_rating_info(player.steam_id)
    template_context["avg_rating"], template_context["rating_amount"] = rating_info
    return render_template("/player/heroes.html", **template_context)
