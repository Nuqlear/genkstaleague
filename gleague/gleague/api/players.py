import re

from flask import Blueprint, jsonify, request
from flask import g
from flask import redirect
from flask import session

from gleague.api import oid
from gleague.models import Player, SeasonStats


_steam_id_re = re.compile('steamcommunity.com/openid/id/(.*?)$')
players_bp = Blueprint('players', __name__)


@players_bp.route('/logout')
def logout():
    session.clear()
    g.user = None
    return redirect("/")


@players_bp.route('/login')
@oid.loginhandler
def login():
    if g.user is not None:
        return redirect("/")
    return oid.try_login('http://steamcommunity.com/openid')


@oid.after_login
def create_or_login(resp):
    match = _steam_id_re.search(resp.identity_url)
    g.user = Player.get_or_create(match.group(1))
    session['steam_id'] = g.user.steam_id
    return redirect("/")


@players_bp.route('/')
def players_list():
    return jsonify({
        'players': [p.to_dict() for p in Player.query.all()]
    })


@players_bp.route('/stats/<int:season_id>')
@players_bp.route('/stats/')
def players_stats(season_id=-1):
    nickname_filter = request.args.get('q', None)
    sort = request.args.get('sort', 'pts')
    items = []
    for season_stats in SeasonStats.get_stats(
        season_id, nickname_filter, sort
    ):
        items.append({
            'steam_id': season_stats.player.steam_id,
            'nickname': season_stats.player.nickname,
            'pts': season_stats.pts,
            'wins': season_stats.wins,
            'loses': season_stats.losses,
            'win_rate': (
                season_stats.wins /
                max(season_stats.wins + season_stats.losses, 1) * 100
            )
        })
    return jsonify({'players': items})
