import re

from flask import Blueprint
from flask import g
from flask import redirect
from flask import session

from gleague.api import oid
from gleague.models import Player

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
