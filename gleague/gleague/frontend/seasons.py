from flask import Blueprint
from flask import abort
from flask import render_template
from flask import request
from flask import current_app
from sqlalchemy import desc

from gleague.core import db
from gleague.models import Match
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models.queries import season_analytic
from gleague.cache import cached


seasons_bp = Blueprint("seasons", __name__)


def get_season_number_and_id(season_number):
    if season_number == -1:
        season = Season.current()
    else:
        season = Season.query.filter(Season.number == season_number).first()
        if not season:
            abort(404)
    return season.number, season.id


@seasons_bp.route("/current/players", methods=["GET"])
@seasons_bp.route("/<int:season_number>/players", methods=["GET"])
@cached([Match])
def players(season_number=-1):
    season_number, s_id = get_season_number_and_id(season_number)
    q = request.args.get("q")
    sort = request.args.get("sort", "pts")
    page = int(request.args.get("page", 1))
    stats = SeasonStats.get_stats(season_number, q, sort)
    stats = stats.paginate(page, current_app.config["TOP_PLAYERS_PER_PAGE"], True)
    seasons = [season[0] for season in db.session.query(Season.number).all()]
    return render_template(
        "/season/players.html",
        stats=stats,
        sort=sort,
        seasons=seasons,
        season_number=season_number,
    )


@seasons_bp.route("/current/records", methods=["GET"])
@seasons_bp.route("/<int:season_number>/records", methods=["GET"])
@cached([Match])
def records(season_number=-1):
    season_number, s_id = get_season_number_and_id(season_number)
    template_context = {
        "season_number": season_number,
        "seasons": [season[0] for season in db.session.query(Season.number).all()],
    }
    longest_match = season_analytic.get_longest_match(s_id)
    if longest_match:
        template_context.update(
            {
                "shortest_match": season_analytic.get_shortest_match(s_id),
                "in_season_player_records": season_analytic.get_in_season_records(s_id),
                "in_match_records": season_analytic.get_in_match_records(s_id),
                "avg_match_duration": season_analytic.get_avg_match_duration(s_id),
                "most_powerful_sups": season_analytic.get_most_powerful_supports(s_id),
                "most_powerful_midlaners": season_analytic.get_most_powerful_midlaners(
                    s_id
                ),
                "side_winrates": season_analytic.get_side_winrates(s_id),
                "powerful_duos": season_analytic.get_most_powerful_duos(s_id),
                "powerless_duos": season_analytic.get_most_powerless_duos(s_id),
            }
        )
    return render_template("/season/records.html", **template_context)


@seasons_bp.route("/current/heroes", methods=["GET"])
@seasons_bp.route("/<int:season_number>/heroes", methods=["GET"])
@cached([Match])
def heroes(season_number=-1):
    season_number, s_id = get_season_number_and_id(season_number)
    sort = request.args.get("sort", "played")
    return render_template(
        "/season/heroes.html",
        season_number=season_number,
        seasons=[season[0] for season in db.session.query(Season.number).all()],
        sort=sort,
        is_desc=desc,
        in_season_heroes=season_analytic.get_player_heroes(s_id, sort),
    )
