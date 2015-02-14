import sqlalchemy
import re

from flask import Blueprint, request, g, abort, jsonify, redirect, session

from ..models import Player
from ..core import db
from .import oid


_steam_id_re = re.compile('steamcommunity.com/openid/id/(.*?)$')

players_bp = Blueprint('players', __name__)


@players_bp.route('/me', methods=['GET'])
def get_active_user():
    if g.user is not None:
        u = g.user
        return jsonify(u.to_dict(True)), 200


@players_bp.route('/logout')
def logout():
    session.pop('steam_id')
    return redirect('')


@players_bp.route('/login')
@oid.loginhandler
def login():
    if g.user is not None:
        return redirect('')
    return oid.try_login('http://steamcommunity.com/openid')


@oid.after_login
def create_or_login(resp):
    match = _steam_id_re.search(resp.identity_url)
    g.user = Player.get_or_create(match.group(1))
    session['steam_id'] = g.user.steam_id
    return redirect('')