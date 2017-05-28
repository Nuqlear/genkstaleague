from functools import wraps

from flask import jsonify
from flask import g
from flask import Response
from flask import current_app
from flask_openid import OpenID

from gleague import core
from gleague import admin

oid = OpenID()


def create_app(name=__name__):
    app = core.create_app(name)

    for e in [401, 403, 404, 500]:
        app.errorhandler(e)(handle_error)

    oid.init_app(app)
    admin.init_admin(app)

    from gleague.api.players import players_bp
    app.register_blueprint(players_bp, url_prefix='/players')

    from gleague.api.matches import matches_bp
    app.register_blueprint(matches_bp, url_prefix='/matches')

    return app


def handle_error(e):
    msg = 'Not Found'
    code = 500

    if hasattr(e, 'msg'):
        msg = e.msg

    if hasattr(e, 'code'):
        code = e.code

    return jsonify({'error': msg}), code


def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not g.user:
            return Response(status=401)
        return f(*args, **kwargs)

    return decorated_function


def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not g.user or g.user.steam_id not in current_app.config['ADMINS_STEAM_ID']:
            return Response(status=403)
        return f(*args, **kwargs)

    return decorated_function
