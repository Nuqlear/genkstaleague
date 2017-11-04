import re

from flask import redirect
from flask import Blueprint
from flask import g
from flask import session

from gleague.frontend import oid
from gleague.models import Player


_steam_id_re = re.compile('steamcommunity.com/openid/id/(.*?)$')
auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/logout')
def logout():
    session.pop('steam_id', None)
    g.user = None
    return redirect(oid.get_next_url())


@auth_bp.route('/login')
@oid.loginhandler
def login():
    if g.user is not None:
        return redirect(oid.get_next_url())
    return oid.try_login('http://steamcommunity.com/openid')


@oid.after_login
def create_or_login(resp):
    match = _steam_id_re.search(resp.identity_url)
    g.user = Player.get_or_create(match.group(1))
    session['steam_id'] = g.user.steam_id
    return redirect('/')
