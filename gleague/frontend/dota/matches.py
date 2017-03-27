import random

from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import desc

from gleague.models import DotaMatch

matches_bp = Blueprint('matches', __name__)


@matches_bp.route('/<int:match_id>', methods=['GET'])
def match(match_id):
    m = DotaMatch.query.get(match_id)
    if not m:
        return abort(404)
    return render_template('dota/match.html', match=m)


@matches_bp.route('/', methods=['GET'])
def matches_preview():
    page = request.args.get('page', '1')
    if not page.isdigit():
        abort(400)
    page = int(page)
    m = DotaMatch.query.order_by(desc(DotaMatch.id)).paginate(page,
                                                              current_app.config['HISTORY_MATCHES_PER_PAGE'], True)
    return render_template('dota/matches.html', matches=m)


# SERGEY
def sort_by_pts(players, t=50):
    def total_pts(players):
        return sum((players[i][1] for i in range(len(players))))

    def pts_diff(radiant, dire):
        return abs(total_pts(radiant) - total_pts(dire))

    def shuffle(players):
        radiant = []
        dire = []
        for i in range(0, len(players), 2):
            if random.randrange(0, 2):
                radiant.append(players[i])
                dire.append(players[i + 1])
            else:
                radiant.append(players[i + 1])
                dire.append(players[i])
        return sorted(radiant, key=lambda a: a[1], reverse=True), sorted(dire, key=lambda a: a[1], reverse=True)

    sorted_players = sorted(players, key=lambda a: a[1])
    best_attempt = shuffle(sorted_players)
    best_diff = pts_diff(*best_attempt)

    for __ in range(t):
        attempt = shuffle(sorted_players)
        diff = pts_diff(*attempt)
        if diff < best_diff:
            best_diff = diff
            best_attempt = attempt

    return best_attempt
