import sqlalchemy
import json

from flask import Blueprint, request, g, abort, jsonify, Response

from ..models import Match
from ..core import db


matches_bp = Blueprint('matches', __name__)


@matches_bp.route('/matches/', methods=['POST'])
def create_match():
    data = request.get_json()
    if data:
        dictionary = json.loads(data)['result']
        m = Match.create_from_dict(dictionary)
        if m is None:
            return Response(status=500)
        return Response(status=201)
    return Response(status=406)


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
        return Response(status=400)
    matches = Match.get_batch(amount, offs)
    return jsonify({'matches':[m.to_dict(False) for m in matches]}), 200
