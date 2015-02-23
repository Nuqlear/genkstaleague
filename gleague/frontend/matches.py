import json

from flask import Blueprint, g, abort, current_app, render_template
from sqlalchemy import desc

from ..models import Match, PlayerMatchRating
from ..core import db
from . import login_required, admin_required

matches_bp = Blueprint('matches', __name__)



@matches_bp.route('/<int:match_id>', methods=['GET'])
def match(match_id):
    m = Match.query.get(match_id)
    if not m:
        return abort(404)
    return render_template('match.html', match = m)


@matches_bp.route('/', methods=['GET'])
@matches_bp.route('/<int:page>', methods=['GET'])
def matches_preview(page=1):
    m = Match.query.order_by(desc(Match.id)).paginate(page,
        current_app.config.get('TOP_PLAYERS_PER_PAGE', 6), True)
    return render_template('matches.html', matches=m)
