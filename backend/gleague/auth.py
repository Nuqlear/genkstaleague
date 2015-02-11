import re
from flask import session, redirect, g, Blueprint
from flask_openid import OpenID

from . import core
from .models import Player


_steam_id_re = re.compile('steamcommunity.com/openid/id/(.*?)$')
oid = OpenID()


def create_app():
    app = core.create_app(__name__)
    oid.init_app(app)

    @app.route('/logout')
    def logout():
        session.pop('user_id')
        return redirect(oid.get_next_url())


    @app.route('/login')
    @oid.loginhandler
    def login():
        if g.user is not None:
            return redirect(oid.get_next_url())
        return oid.try_login('http://steamcommunity.com/openid')


    @oid.after_login
    def create_or_login(resp):
        match = _steam_id_re.search(resp.identity_url)
        g.user = Player.get_or_create(match.group(1))
        session['user_id'] = g.user.steam_id
        return redirect(oid.get_next_url())

    return app
