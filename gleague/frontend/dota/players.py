import json

from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import and_
from sqlalchemy import desc

from gleague.models import DotaPlayer
from gleague.models import DotaPlayerMatchStats
from gleague.models import DotaSeason
from gleague.models import DotaSeasonStats

players_bp = Blueprint('players', __name__)


def get_season_stats(cs_id, player):
    stats = player.dota_season_stats[0]
    if player.dota_season_stats[0].season_id != cs_id:
        return {'wins': 0, 'losses': 0, 'pts': 1000}
    else:
        return stats


@players_bp.route('/<int:steam_id>/', methods=['GET'])
@players_bp.route('/<int:steam_id>/overview', methods=['GET'])
def overview(steam_id):
    p = DotaPlayer.get_or_create(steam_id)
    if not p:
        return abort(404)
    cs_id = DotaSeason.current().id
    stats = DotaPlayerMatchStats.query.join(DotaSeasonStats).filter(DotaSeasonStats.steam_id == steam_id) \
        .order_by(desc(DotaPlayerMatchStats.match_id)).limit(8)
    pts_seq = DotaPlayerMatchStats.query.join(DotaSeasonStats).filter(and_(DotaSeasonStats.season_id == cs_id,
                                                                           DotaSeasonStats.steam_id == steam_id)).order_by(
        DotaPlayerMatchStats.match_id) \
        .values(DotaPlayerMatchStats.old_pts + DotaPlayerMatchStats.pts_diff)
    pts_hist = [[0, 1000]]
    for index, el in enumerate(pts_seq):
        pts_hist.append([index + 1, el[0]])
    rating_info = p.get_avg_rating()[0]
    avg_rating = rating_info[0] or 0
    rating_amount = rating_info[1]
    signature_heroes = p.get_heroes(cs_id).order_by(desc('played')).limit(3).all()
    matches_stats = stats.all()
    season_stats = get_season_stats(cs_id, p)
    return render_template('dota/player_overview.html', player=p, season_stats=season_stats, avg_rating=avg_rating,
                           rating_amount=rating_amount, signature_heroes=signature_heroes, matches_stats=matches_stats,
                           pts_history=json.dumps(pts_hist))


@players_bp.route('/<int:steam_id>/matches', methods=['GET'])
def matches(steam_id):
    p = DotaPlayer.query.get(steam_id)
    if not p:
        return abort(404)
    _args = {'player': p}
    page = request.args.get('page', '1')
    if not page.isdigit():
        abort(400)
    page = int(page)
    hero_filter = request.args.get('hero', None)
    cs_id = DotaSeason.current().id
    matches_stats = DotaPlayerMatchStats.query.order_by(desc(DotaPlayerMatchStats.match_id)) \
        .join(DotaSeasonStats).filter(DotaSeasonStats.steam_id == steam_id)
    if hero_filter:
        _args['hero_filter'] = hero_filter
        matches_stats = matches_stats.filter(DotaPlayerMatchStats.hero == hero_filter)
    _args['matches_stats'] = matches_stats.paginate(page,
                                                    current_app.config['PLAYER_HISTORY_MATCHES_PER_PAGE'], True)
    rating_info = p.get_avg_rating()[0]
    _args['avg_rating'] = rating_info[0] or 0
    _args['rating_amount'] = rating_info[1]
    _args['season_stats'] = get_season_stats(cs_id, p)
    return render_template('dota/player_matches.html', **_args)


@players_bp.route('/<int:steam_id>/heroes', methods=['GET'])
def heroes(steam_id):
    p = DotaPlayer.query.get(steam_id)
    if not p:
        return abort(404)
    _sort = request.args.get('sort', 'played')
    if _sort not in ['hero', 'played', 'pts_diff', 'winrate', 'kda']:
        _sort = 'played'
    order_by = _sort
    _desc = request.args.get('desc', 'yes')
    if _desc != 'no':
        _desc = 'yes'
        order_by = desc(order_by)
    _args = {'player': p, 'sort': _sort, 'desc': _desc}
    hero_filter = request.args.get('hero', None)
    cs_id = DotaSeason.current().id
    heroes_stats = p.get_heroes(cs_id).order_by(order_by).all()
    _args['heroes_stats'] = heroes_stats
    rating_info = p.get_avg_rating()[0]
    _args['avg_rating'] = rating_info[0] or 0
    _args['rating_amount'] = rating_info[1]
    _args['season_stats'] = get_season_stats(cs_id, p)
    return render_template('dota/player_heroes.html', **_args)
