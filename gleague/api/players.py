import sqlalchemy
import re

from flask import Blueprint
from flask import request
from flask import g
from flask import abort
from flask import jsonify
from flask import redirect
from flask import session
from flask import Response
from flask import abort

from gleague.models import Player
from gleague.core import db
from gleague.api import oid


_steam_id_re = re.compile('steamcommunity.com/openid/id/(.*?)$')

players_bp = Blueprint('players', __name__)


@players_bp.route('/logout')
def logout():
    session.clear()
    g.user = None
    return redirect("/", code=302)


@players_bp.route('/login')
@oid.loginhandler
def login():
    if g.user is not None:
        return redirect("/", code=302)
    return oid.try_login('http://steamcommunity.com/openid')


@oid.after_login
def create_or_login(resp):
    match = _steam_id_re.search(resp.identity_url)
    g.user = Player.get_or_create(match.group(1))
    session['steam_id'] = g.user.steam_id
    return redirect("/", code=302)
