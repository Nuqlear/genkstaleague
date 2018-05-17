import random
from collections import namedtuple

from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import desc

from gleague.models import Match, Season, SeasonStats, Player

matches_bp = Blueprint('matches', __name__)


@matches_bp.route('/<int:match_id>', methods=['GET'])
def match(match_id):
    m = Match.query.get(match_id)
    if not m:
        return abort(404)
    return render_template('redesign/match.html', match=m)


@matches_bp.route('/', methods=['GET'])
def matches_preview():
    page = request.args.get('page', '1')
    if not page.isdigit():
        abort(400)
    page = int(page)
    m = Match.query.order_by(desc(Match.id)).paginate(
        page, current_app.config['HISTORY_MATCHES_PER_PAGE'], True
    )
    return render_template('redesign/matches.html', matches=m)


PlayerTuple = namedtuple('PlayerTuple', ['nickname', 'pts'])


@matches_bp.route('/team_builder', methods=['GET', 'POST'])
def team_builder():
    cs_id = Season.current().id
    season_stats = (
        sorted(
            SeasonStats.query.filter(SeasonStats.season_id == cs_id).all(),
            key=lambda ss: ss.player.nickname.lower()
        )
    )
    context = {
        'season_stats': season_stats
    }
    if request.method == 'POST':
        players = []
        for i in range(1, 11):
            player_id = request.form.get('player-%i' % i)
            if player_id == 'None':
                players.append(
                    PlayerTuple(
                        'NOT REGISTERED PLAYER', SeasonStats.pts.default.arg
                    )
                )
            else:
                p = Player.query.get(player_id)
                players.append(PlayerTuple(p.nickname, p.season_stats[0].pts))
        context['teams'] = sort_by_pts(players)
    return render_template('redesign/team_builder.html', **context)


def sort_by_pts(players, t=50):
    def total_pts(players):
        return sum((players[i].pts for i in range(len(players))))

    def pts_diff(radiant, dire):
        return abs(total_pts(radiant) - total_pts(dire))

    def shuffle(players):
        teams = [[], []]
        radiant = teams[0]
        dire = teams[1]
        for i in range(0, len(players), 2):
            if random.randrange(0, 2):
                radiant.append(players[i])
                dire.append(players[i + 1])
            else:
                radiant.append(players[i + 1])
                dire.append(players[i])
        return teams

    sorted_players = sorted(players, key=lambda p: p.pts)
    best_attempt = shuffle(sorted_players)
    best_diff = pts_diff(*best_attempt)

    for __ in range(t):
        attempt = shuffle(sorted_players)
        diff = pts_diff(*attempt)
        if diff < best_diff:
            best_diff = diff
            best_attempt = attempt

    return best_attempt
