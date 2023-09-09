import logging

from flask import Blueprint
from flask import Response
from flask import abort
from flask import g
from flask import jsonify
from flask import request
from flask import current_app

from gleague.auth import admin_required
from gleague.auth import login_required
from gleague.core import db
from gleague.models import Match
from gleague.models import PlayerMatchRating
from gleague.models import TeamSeed
from gleague.replays import ReplayParserService
from gleague.replays import ReplayDataProcessor


matches_bp = Blueprint("matches", __name__)


@matches_bp.route("/", methods=["POST"])
@admin_required
def create_match():
    replay = request.files["file"]
    if replay:
        base_pts_diff = current_app.config.get("MATCH_BASE_PTS_DIFF", 20)
        seed_id = request.form.get("seed_id")
        team_seed = TeamSeed.query.get(seed_id) if seed_id else None
        try:
            parser = ReplayParserService(current_app.config["REPLAY_PARSER_HOST"])
            replay_data = parser.parse_replay(replay)
            replay_processor = ReplayDataProcessor(
                base_pts_diff,
                current_app.config.get("DOUBLE_DOWN_FROM_DOUBLE_DOWN", False),
            )
            replay_processor.save_replay_data(replay_data, team_seed)
        except Exception as exc:
            logging.error("Creating match from replay failed: %s", str(exc))
            abort(400)
        return Response(status=201)
    return abort(400)


@matches_bp.route("/<int:match_id>/ratings/", methods=["GET"])
def get_rates(match_id):
    if not Match.is_exists(match_id):
        return abort(404)
    steam_id = g.user.steam_id if g.user else None
    ratings = PlayerMatchRating.get_match_ratings(match_id, steam_id)
    return jsonify({"ratings": ratings}), 200


@matches_bp.route(
    "/<int:match_id>/ratings/<int:player_match_stats_id>", methods=["POST"]
)
@login_required
def rate_player(match_id, player_match_stats_id):
    rating = request.args.get("rating", None)
    try:
        rating = int(rating)
    except Exception:
        return abort(400)
    match = Match.query.get(match_id)
    if not match:
        return abort(404)
    if rating not in range(1, 6):
        return abort(406)
    if not match.is_played(g.user.steam_id):
        return abort(403)
    db.session.add(
        PlayerMatchRating(
            player_match_stats_id=player_match_stats_id,
            rating=rating,
            rated_by_steam_id=g.user.steam_id,
        )
    )
    db.session.flush()
    return Response(status=200)
