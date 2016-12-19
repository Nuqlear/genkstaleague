import json
import random

from flask import Blueprint, g, abort, current_app, render_template, request
from sqlalchemy import desc

from ..models import DotaMatch, DotaSeasonStats, DotaSeason, Player
from ..core import db
from . import login_required, admin_required

matches_bp = Blueprint('matches', __name__)



@matches_bp.route('/<int:match_id>', methods=['GET'])
def match(match_id):
    m = DotaMatch.query.get(match_id)
    if not m:
        return abort(404)
    return render_template('match.html', match = m)


@matches_bp.route('/', methods=['GET'])
def matches_preview():
    page = request.args.get('page', '1')
    if not page.isdigit():
        abort(400)
    page = int(page)
    m = DotaMatch.query.order_by(desc(DotaMatch.id)).paginate(page,
        current_app.config['HISTORY_MATCHES_PER_PAGE'], True)
    return render_template('matches.html', matches=m)


@matches_bp.route('/team_builder', methods=['GET', 'POST'])
def team_builder():
    cs_id = DotaSeason.current().id
    season_stats = DotaSeasonStats.query.filter(DotaSeasonStats.season_id==cs_id).all()
    if request.method == 'POST':
        players = []
        for i in range(1, 11):
            player_id = request.form.get('player-%i' %i)
            if player_id == 'None':
                players.append(['NOT REGISTERED PLAYER', DotaSeasonStats.pts.default.arg])
            else:
                p = Player.query.get(player_id)
                players.append([p.nickname, p.season_stats[0].pts])
        players = sort_by_pts(players)
        return render_template('team_builder.html', season_stats=season_stats, players=players)
    return render_template('team_builder.html', season_stats=season_stats)


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
