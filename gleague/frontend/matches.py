import sqlalchemy
import json

from flask import Blueprint, request, g, abort, jsonify, Response, render_template

from ..models import Match, PlayerMatchRating
from ..core import db
from . import login_required, admin_required

matches_bp = Blueprint('matches', __name__)



@matches_bp.route('/<int:match_id>', methods=['GET'])
def get_match(match_id):
    m = Match.query.get(match_id)
    if not m:
        return abort(status=404)
    return render_template('match.html', match = m)


# @matches_bp.route('/', methods=['GET'])
# def get_matches_preview():
#     amount = request.args.get('amount', 4)
#     offs = request.args.get('offset', 0)
#     try:
#         amount = int(amount)
#         offs = int(offs)
#     except Exception:
#         return abort(status=406)
#     matches = Match.get_batch(amount, offs)
#     return jsonify({'matches':[m.to_dict(False) for m in matches]}), 200
