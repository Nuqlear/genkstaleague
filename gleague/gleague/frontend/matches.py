from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from flask import redirect
from flask import url_for
from flask import g
from sqlalchemy import desc

from gleague.core import db
from gleague.models import Match
from gleague.models import Season
from gleague.models import TeamSeed
from gleague.models.queries.match_analytic import get_teams_stats_history
from gleague.team_builder import TeamBuilderService


matches_bp = Blueprint("matches", __name__)


@matches_bp.route("/<int:match_id>", methods=["GET"])
def match(match_id):
    match = Match.query.get(match_id)
    if not match:
        return abort(404)
    teams_stats_history = get_teams_stats_history(match)
    return render_template(
        "/match.html",
        match=match,
        teams_stats_history=teams_stats_history.to_dict()
        if teams_stats_history
        else None,
    )


@matches_bp.route("/", methods=["GET"])
def matches_preview():
    page = request.args.get("page", "1")
    if not page.isdigit():
        abort(400)
    page = int(page)
    matches = Match.query.order_by(desc(Match.id)).paginate(
        page, current_app.config["HISTORY_MATCHES_PER_PAGE"], True
    )
    return render_template("/matches.html", matches=matches)


@matches_bp.route("/team_builder", methods=["GET", "POST"])
@matches_bp.route("/team_builder/<seed_id>", methods=["GET", "POST"])
def team_builder(seed_id=None):
    seed = None
    season = Season.current()
    builder = TeamBuilderService(season)
    player_ids = []

    if seed_id is not None:
        seed = TeamSeed.query.get(str(seed_id))
        if seed is None:
            abort(404)
        if seed.match:
            return redirect(url_for("matches.match", match_id=seed.match.id))
        player_ids = [p.steam_id for p in seed.team_seed_players]

    if request.method == "POST":
        player_ids = [
            request.form.get("player-%i" % num) or None for num in range(1, 11)
        ]
        teams = builder.shuffle_teams(player_ids)
        seed = builder.save_seed(teams)
        db.session.commit()
        return redirect(url_for("matches.team_builder", seed_id=seed.id))
    elif "from_match_id" in request.args and not seed_id:
        from_match_id = request.args.get("from_match_id")
        match = Match.query.get(from_match_id)
        player_ids = [ps.season_stats.steam_id for ps in match.players_stats]
        teams = builder.shuffle_teams(player_ids)

    user_seed = None
    if g.user:
        for seed_player in seed and seed.team_seed_players or []:
            if seed_player.steam_id == g.user.steam_id:
                user_seed = seed_player
                break

    return render_template(
        "/team_builder.html",
        players=builder.get_players(),
        seed=seed,
        selected_player_ids=player_ids,
        user_seed=user_seed,
    )
