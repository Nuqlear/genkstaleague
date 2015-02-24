import json

from flask import Blueprint, g, abort, current_app, render_template, request, current_app
from sqlalchemy import desc, func

from ..models import Player, PlayerMatchStats, SeasonStats, Season
from ..core import db
from . import login_required, admin_required

players_bp = Blueprint('players', __name__)



@players_bp.route('/<int:steam_id>/', methods=['GET'])
@players_bp.route('/<int:steam_id>/overview', methods=['GET'])
def player_overview(steam_id):
    p = Player.query.get(steam_id)
    if not p:
        return abort(404)
    stats = PlayerMatchStats.query.join(SeasonStats).filter(SeasonStats.steam_id==steam_id)\
        .order_by(desc(PlayerMatchStats.match_id)).limit(8)
    rating_info = p.get_avg_rating()[0]
    avg_rating = rating_info[0] or 0
    rating_amount = rating_info[1]
    signature_heroes = p.get_signature_heroes()
    matches_stats = stats.all()
    return render_template('player_overview.html', player = p, avg_rating=avg_rating,
        rating_amount=rating_amount, signature_heroes=signature_heroes, matches_stats=matches_stats)



@players_bp.route('/', methods=['GET'])
def players():
    q = request.args.get('q')
    sort = request.args.get('sort', 'pts')
    sort_dict = {'pts':desc(SeasonStats.pts), 'nickname':desc(Player.nickname),
        'wins':desc(SeasonStats.wins), 'losses':desc(SeasonStats.losses)}
    page = request.args.get('page', 1)
    page = int(page)
    cs_id = Season.current().id
    ss = SeasonStats.query.join(Player).filter(SeasonStats.season_id==cs_id)\
        .order_by(sort_dict.get(sort, desc(SeasonStats.pts)))
    if q:
        ss = ss.filter(func.lower(Player.nickname).startswith(func.lower(q)))
    ss = ss.paginate(page, current_app.config.get('TOP_PLAYERS_PER_PAGE', 15), True)
    return render_template('players.html', stats=ss)
