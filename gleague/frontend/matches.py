from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import desc

from gleague.models import Match


matches_bp = Blueprint('matches', __name__)


@matches_bp.route('/<int:match_id>', methods=['GET'])
def match(match_id):
    m = Match.query.get(match_id)
    if not m:
        return abort(404)
    return render_template('match.html', match=m)


@matches_bp.route('/', methods=['GET'])
def matches_preview():
    page = request.args.get('page', '1')
    if not page.isdigit():
        abort(400)
    page = int(page)
    m = Match.query.order_by(desc(Match.id)).paginate(
        page, current_app.config['HISTORY_MATCHES_PER_PAGE'], True
    )
    return render_template('matches.html', matches=m)
