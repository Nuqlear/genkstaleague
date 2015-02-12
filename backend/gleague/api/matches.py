import sqlalchemy
import json

from flask import Blueprint, request, g, abort, jsonify, Response

from ..models import Match, PlayerMatchRating
from ..core import db
from . import login_required, admin_required

matches_bp = Blueprint('matches', __name__)


@matches_bp.route('/matches/', methods=['POST'])
@admin_required
def create_match():
    data = request.get_json()
    if data:
        dictionary = json.loads(data)['result']
        m = Match.create_from_dict(dictionary)
        if m is None:
            return Response(status=500)
        return Response(status=201)
    return Response(status=400)


@matches_bp.route('/matches/<int:match_id>/', methods=['GET'])
def get_match(match_id):
    m = Match.query.get(match_id)
    if not m:
        return Response(status=404)
    return jsonify(m.to_dict()), 200


@matches_bp.route('/matches/', methods=['GET'])
def get_matches_preview():
    amount = request.args.get('amount', 4)
    offs = request.args.get('offset', 0)
    try:
        amount = int(amount)
        offs = int(offs)
    except Exception:
        return Response(status=406)
    matches = Match.get_batch(amount, offs)
    return jsonify({'matches':[m.to_dict(False) for m in matches]}), 200


@matches_bp.route('/matches/<int:match_id>/ratings/<int:player_match_stats_id>/', methods=['POST'])
@login_required
def rate_player(match_id, player_match_stats_id):
    rating = request.args.get('rating', None)
    try:
        rating = int(rating)
    except Exception:
        return Response(status=400)
    m = Match.query.get(match_id)
    if not m:
        return Response(status=404)
    if rating not in range(1, 6):
        return Response(status=406)
    if not m.is_played(g.user.steam_id):
        return Response(status=403)
    pmr = PlayerMatchRating(player_match_stats_id=player_match_stats_id, rating=rating, rated_by_steam_id=g.user.steam_id)
    db.session.add(pmr)
    db.session.commit()
    return Response(status=200)

@matches_bp.route('/matches/<int:match_id>/ratings/', methods=['GET'])
def get_rates(match_id):
    if not Match.is_exists(match_id):
        return Response(status=404)
    steam_id = g.user.steam_id if g.user else None
    ratings = PlayerMatchRating.get_match_ratings(match_id, steam_id)
    return jsonify({'ratings':ratings}), 200
