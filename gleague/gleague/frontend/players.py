import json

from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import desc, and_, or_
from sqlalchemy.orm import aliased

from gleague.models import Player
from gleague.models import PlayerMatchStats
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models import Role
from gleague.models.queries import player_analytic
from gleague.models.queries.season_analytic import get_signature_teammates
from gleague.models.queries.season_analytic import get_signature_opponents
from gleague.models.queries.season_analytic import SignatureTeammatesOrder
from gleague.models.queries.season_analytic import SignatureOpponentOrder
from gleague.models.queries.season_analytic import get_playstyles
from gleague.utils.position import Position


players_bp = Blueprint("players", __name__)


def get_season_stats(season_id, player):
    """
    Return stats for a specific season if season_id is not None,
    otherwise return overall aggregated stats across all seasons.
    """
    if season_id is not None:
        stats = (
            player.season_stats.filter(SeasonStats.season_id == season_id).first()
        )
        if not stats:
            return {"wins": 0, "losses": 0, "pts": 1000}
        return stats

    # overall stats across all seasons: compute wins / losses from
    # actual matches so they are consistent with heroes & matches tabs
    stats_list = player.season_stats.all()
    if not stats_list:
        return {"wins": 0, "losses": 0, "pts": 1000}

    wins_losses_query = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(SeasonStats.steam_id == player.steam_id)
    )
    wins = wins_losses_query.filter(PlayerMatchStats.pts_diff > 0).count()
    losses = wins_losses_query.filter(PlayerMatchStats.pts_diff < 0).count()

    return {
        "wins": wins,
        "losses": losses,
        # show current rating (latest season by default ordering)
        "pts": stats_list[0].pts,
    }


def _get_season_selection():
    """
    Parse `season` query param.

    Returns dict with:
      - season_id: Season.id or None for overall
      - season_number: Season.number or None for overall
      - season_param: original string for URLs (e.g. "3", "overall", or None)
      - is_overall: bool
      - seasons: list of Season objects (all seasons, newest first)
    """
    season_param = request.args.get("season")
    current_season = Season.current()
    seasons = Season.query.order_by(Season.number.desc()).all()

    is_overall = False
    selected_season = None

    if season_param is None:
        selected_season = current_season
    elif season_param == "overall":
        is_overall = True
    elif season_param.isdigit():
        selected_season = Season.query.filter(
            Season.number == int(season_param)
        ).first()
        if not selected_season:
            abort(404)
    else:
        abort(400)

    season_id = selected_season.id if selected_season is not None else None
    season_number = selected_season.number if selected_season is not None else None

    return {
        "season_id": season_id,
        "season_number": season_number,
        "season_param": season_param,
        "is_overall": is_overall,
        "seasons": seasons,
    }


@players_bp.route("/<int:steam_id>/", methods=["GET"])
@players_bp.route("/<int:steam_id>/overview", methods=["GET"])
def overview(steam_id):
    player = Player.query.filter(Player.steam_id == steam_id).first()
    if not player:
        return abort(404)
    current_season_id = Season.current().id
    season_ctx = _get_season_selection()
    season_id = season_ctx["season_id"]
    matches_stats = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(SeasonStats.steam_id == steam_id)
        .filter(
            SeasonStats.season_id == season_id
            if season_id is not None
            else True
        )
        .order_by(desc(PlayerMatchStats.match_id))
        .limit(current_app.config["PLAYER_OVERVIEW_MATCHES_AMOUNT"])
        .all()
    )
    signature_heroes = (
        player_analytic.get_heroes(player.steam_id, season_id)
        .order_by(desc("played"))
        .limit(3)
        .all()
    )
    avg_rating, rating_amount = player_analytic.get_rating_info(
        player.steam_id, season_id=season_id
    )
    best_team_mates = get_signature_teammates(
        season_id,
        SignatureTeammatesOrder.win_loss,
        is_asc=False,
        player_id=steam_id,
        limit=3,
    )
    worst_team_mates = get_signature_teammates(
        season_id,
        SignatureTeammatesOrder.win_loss,
        player_id=steam_id,
        limit=3,
    )
    losses_to = get_signature_opponents(
        season_id,
        steam_id,
        SignatureOpponentOrder.win_loss,
        limit=3
    )
    wins_against = get_signature_opponents(
        season_id,
        steam_id,
        SignatureOpponentOrder.win_loss,
        is_asc=False,
        limit=3,
    )
    playstyles = get_playstyles(season_id, steam_id)
    return render_template(
        "/player/overview.html",
        player=player,
        season_stats=get_season_stats(season_id, player),
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
            player_analytic.get_pts_history(steam_id, season_id=season_id)
        ),
        seasons=season_ctx["seasons"],
        selected_season_number=season_ctx["season_number"],
        selected_season_param=season_ctx["season_param"],
        is_overall=season_ctx["is_overall"],
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
    season_ctx = _get_season_selection()
    season_id = season_ctx["season_id"]
    matches_stats = (
        PlayerMatchStats.query.order_by(desc(PlayerMatchStats.match_id))
        .join(SeasonStats)
        .filter(SeasonStats.steam_id == steam_id)
        .filter(
            SeasonStats.season_id == season_id
            if season_id is not None
            else True
        )
    )
    template_context = {
        "player": player,
        "seasons": season_ctx["seasons"],
        "selected_season_number": season_ctx["season_number"],
        "selected_season_param": season_ctx["season_param"],
        "is_overall": season_ctx["is_overall"],
    }
    hero_filter = request.args.get("hero")
    if hero_filter:
        template_context["hero_filter"] = hero_filter
        matches_stats = matches_stats.filter(PlayerMatchStats.hero == hero_filter)

    # Optional role filter (Playstyle section)
    role_filter = request.args.get("role")
    if role_filter:
        template_context["role_filter"] = role_filter
        if role_filter == "Support":
            matches_stats = matches_stats.filter(
                PlayerMatchStats.role == Role.support
            )
        elif role_filter == "Midlane":
            matches_stats = matches_stats.filter(
                PlayerMatchStats.role == Role.core,
                PlayerMatchStats.position == Position.middle,
            )
        elif role_filter == "Safelane":
            matches_stats = matches_stats.filter(
                PlayerMatchStats.role == Role.core,
                or_(
                    and_(
                        PlayerMatchStats.position == Position.bottom,
                        PlayerMatchStats.player_slot < 5,
                    ),
                    and_(
                        PlayerMatchStats.position == Position.top,
                        PlayerMatchStats.player_slot > 5,
                    ),
                ),
            )
        elif role_filter == "Offlane":
            matches_stats = matches_stats.filter(
                PlayerMatchStats.role == Role.core,
                or_(
                    and_(
                        PlayerMatchStats.position == Position.bottom,
                        PlayerMatchStats.player_slot > 5,
                    ),
                    and_(
                        PlayerMatchStats.position == Position.top,
                        PlayerMatchStats.player_slot < 5,
                    ),
                ),
            )

    # Optional teammate / opponent filters (Signature teammates/opponents)
    teammate_id = request.args.get("teammate")
    if teammate_id:
        if not teammate_id.isdigit():
            abort(400)
        teammate_id_int = int(teammate_id)
        template_context["teammate_id"] = teammate_id_int
        pms2 = aliased(PlayerMatchStats)
        ss2 = aliased(SeasonStats)
        matches_stats = (
            matches_stats.join(
                pms2,
                pms2.match_id == PlayerMatchStats.match_id,
            )
            .join(
                ss2,
                ss2.id == pms2.season_stats_id,
            )
            .filter(
                ss2.steam_id == teammate_id_int,
                or_(
                    and_(
                        PlayerMatchStats.player_slot < 5,
                        pms2.player_slot < 5,
                    ),
                    and_(
                        PlayerMatchStats.player_slot >= 5,
                        pms2.player_slot >= 5,
                    ),
                ),
            )
        )

    opponent_id = request.args.get("opponent")
    if opponent_id:
        if not opponent_id.isdigit():
            abort(400)
        opponent_id_int = int(opponent_id)
        template_context["opponent_id"] = opponent_id_int
        pms3 = aliased(PlayerMatchStats)
        ss3 = aliased(SeasonStats)
        matches_stats = (
            matches_stats.join(
                pms3,
                pms3.match_id == PlayerMatchStats.match_id,
            )
            .join(
                ss3,
                ss3.id == pms3.season_stats_id,
            )
            .filter(
                ss3.steam_id == opponent_id_int,
                or_(
                    and_(
                        PlayerMatchStats.player_slot < 5,
                        pms3.player_slot >= 5,
                    ),
                    and_(
                        PlayerMatchStats.player_slot >= 5,
                        pms3.player_slot < 5,
                    ),
                ),
            )
        )
    template_context["matches_stats"] = matches_stats.paginate(
        page, current_app.config["PLAYER_HISTORY_MATCHES_PER_PAGE"], True
    )
    (
        template_context["avg_rating"],
        template_context["rating_amount"],
    ) = player.get_rating_info()
    template_context["season_stats"] = get_season_stats(season_id, player)
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
    season_ctx = _get_season_selection()
    season_id = season_ctx["season_id"]
    heroes_stats = (
        player_analytic.get_heroes(player.steam_id, season_id)
        .order_by(order_by)
        .all()
    )
    template_context = {
        "player": player,
        "sort": sort,
        "desc": is_desc,
        "heroes_stats": heroes_stats,
        "season_stats": get_season_stats(season_id, player),
        "seasons": season_ctx["seasons"],
        "selected_season_number": season_ctx["season_number"],
        "selected_season_param": season_ctx["season_param"],
        "is_overall": season_ctx["is_overall"],
    }
    rating_info = player_analytic.get_rating_info(
        player.steam_id, season_id=season_id
    )
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
    season_ctx = _get_season_selection()
    season_id = season_ctx["season_id"]
    order_by = getattr(SignatureOpponentOrder, sort)
    opponents = get_signature_opponents(
        season_id,
        steam_id,
        order_by,
        is_asc=is_asc,
    )
    template_context = {
        "player": player,
        "sort": sort,
        "desc": is_desc,
        "opponents": opponents,
        "season_stats": get_season_stats(season_id, player),
        "seasons": season_ctx["seasons"],
        "selected_season_number": season_ctx["season_number"],
        "selected_season_param": season_ctx["season_param"],
        "is_overall": season_ctx["is_overall"],
    }
    rating_info = player_analytic.get_rating_info(
        player.steam_id, season_id=season_id
    )
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
    season_ctx = _get_season_selection()
    season_id = season_ctx["season_id"]
    order_by = getattr(SignatureTeammatesOrder, sort)
    teammates = get_signature_teammates(
        season_id,
        order_by,
        player_id=steam_id,
        is_asc=is_asc,
    )
    template_context = {
        "player": player,
        "sort": sort,
        "desc": is_desc,
        "teammates": teammates,
        "season_stats": get_season_stats(season_id, player),
        "seasons": season_ctx["seasons"],
        "selected_season_number": season_ctx["season_number"],
        "selected_season_param": season_ctx["season_param"],
        "is_overall": season_ctx["is_overall"],
    }
    rating_info = player_analytic.get_rating_info(
        player.steam_id, season_id=season_id
    )
    template_context["avg_rating"], template_context["rating_amount"] = rating_info
    return render_template("/player/teammates.html", **template_context)
