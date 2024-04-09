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
from gleague.models.queries.season_analytic import get_signature_teammates
from gleague.models.queries.season_analytic import get_signature_opponents
from gleague.models.queries.season_analytic import SignatureTeammatesOrder
from gleague.models.queries.season_analytic import SignatureOpponentOrder
from gleague.models.queries.season_analytic import get_playstyles


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
    best_team_mates = get_signature_teammates(
        current_season_id,
        SignatureTeammatesOrder.win_loss,
        is_asc=False,
        player_id=steam_id,
        limit=3,
    )
    worst_team_mates = get_signature_teammates(
        current_season_id,
        SignatureTeammatesOrder.win_loss,
        player_id=steam_id,
        limit=3,
    )
    losses_to = get_signature_opponents(
        current_season_id,
        steam_id,
        SignatureOpponentOrder.win_loss,
        limit=3
    )
    wins_against = get_signature_opponents(
        current_season_id,
        steam_id,
        SignatureOpponentOrder.win_loss,
        is_asc=False,
        limit=3,
    )
    playstyles = get_playstyles(current_season_id, steam_id)
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
        losses_to=losses_to,
        wins_against=wins_against,
        playstyles=playstyles,
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
    (
        template_context["avg_rating"],
        template_context["rating_amount"],
    ) = player.get_rating_info()
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


@players_bp.route("/<int:steam_id>/opponents", methods=["GET"])
def opponents(steam_id):
    player = Player.query.get(steam_id)
    if not player:
        return abort(404)
    sort = request.args.get("sort", "games_played")
    is_desc = request.args.get("desc", "yes")
    is_asc = is_desc != "yes"
    current_season_id = Season.current().id
    order_by = getattr(SignatureOpponentOrder, sort)
    opponents = get_signature_opponents(
        current_season_id,
        steam_id,
        order_by,
        is_asc=is_asc,
    )
    template_context = {
        "player": player,
        "sort": sort,
        "desc": is_desc,
        "opponents": opponents,
        "season_stats": get_season_stats(current_season_id, player),
    }
    rating_info = player_analytic.get_rating_info(player.steam_id)
    template_context["avg_rating"], template_context["rating_amount"] = rating_info
    return render_template("/player/opponents.html", **template_context)


@players_bp.route("/<int:steam_id>/teammates", methods=["GET"])
def teammates(steam_id):
    player = Player.query.get(steam_id)
    if not player:
        return abort(404)
    sort = request.args.get("sort", "games_played")
    is_desc = request.args.get("desc", "yes")
    is_asc = is_desc != "yes"
    current_season_id = Season.current().id
    order_by = getattr(SignatureTeammatesOrder, sort)
    teammates = get_signature_teammates(
        current_season_id,
        order_by,
        player_id=steam_id,
        is_asc=is_asc,
    )
    template_context = {
        "player": player,
        "sort": sort,
        "desc": is_desc,
        "teammates": teammates,
        "season_stats": get_season_stats(current_season_id, player),
    }
    rating_info = player_analytic.get_rating_info(player.steam_id)
    template_context["avg_rating"], template_context["rating_amount"] = rating_info
    return render_template("/player/teammates.html", **template_context)
