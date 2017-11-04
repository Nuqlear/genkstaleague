from flask import Blueprint
from flask import Response
from flask import abort
from flask import g
from flask import jsonify
from flask import request

from gleague.api import admin_required
from gleague.api import login_required
from gleague.core import db
from gleague.models import Match
from gleague.models import PlayerMatchRating


matches_bp = Blueprint('matches', __name__)


@matches_bp.route('/', methods=['POST'])
@admin_required
def create_match():
    replay = request.files['file']
    if replay:
        Match.create_from_replay_fs(replay)
        # if m is None:
        #     return abort(500)
        return Response(status=201)
    return abort(400)


@matches_bp.route('/<int:match_id>', methods=['GET'])
def get_match(match_id):
    m = Match.query.get(match_id)
    if not m:
        return abort(404)
    return jsonify(m.to_dict()), 200


@matches_bp.route('/', methods=['GET'])
def get_matches_preview():
    amount = request.args.get('amount', 4)
    offs = request.args.get('offset', 0)
    try:
        amount = int(amount)
        offs = int(offs)
    except Exception:
        return abort(406)
    matches = Match.get_batch(amount, offs)
    return jsonify({'matches': [m.to_dict(False) for m in matches]}), 200


@matches_bp.route('/<int:match_id>/ratings/', methods=['GET'])
def get_rates(match_id):
    if not Match.is_exists(match_id):
        return abort(404)
    steam_id = g.user.steam_id if g.user else None
    ratings = PlayerMatchRating.get_match_ratings(match_id, steam_id)
    return jsonify({'ratings': ratings}), 200


@matches_bp.route(
    '/<int:match_id>/ratings/<int:player_match_stats_id>', methods=['POST']
)
@login_required
def rate_player(match_id, player_match_stats_id):
    rating = request.args.get('rating', None)
    try:
        rating = int(rating)
    except Exception:
        return abort(400)
    m = Match.query.get(match_id)
    if not m:
        return abort(404)
    if rating not in range(1, 6):
        return abort(406)
    if not m.is_played(g.user.steam_id):
        return abort(403)
    db.session.add(
        PlayerMatchRating(
            player_match_stats_id=player_match_stats_id,
            rating=rating,
            rated_by_steam_id=g.user.steam_id
        )
    )
    db.session.flush()
    return Response(status=200)
