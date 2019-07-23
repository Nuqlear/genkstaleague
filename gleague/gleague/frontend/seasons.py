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
def records(season_number=-1):
    season_number, s_id = get_season_number_and_id(season_number)
    template_context = {
        "season_number": season_number,
        "seasons": [season[0] for season in db.session.query(Season.number).all()],
    }
    template_context.update(season_analytic.get_all_season_records(season_number))
    return render_template("/season/records.html", **template_context)


@seasons_bp.route("/current/heroes", methods=["GET"])
@seasons_bp.route("/<int:season_number>/heroes", methods=["GET"])
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
