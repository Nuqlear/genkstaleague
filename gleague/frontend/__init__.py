from flask import jsonify, g, Response, current_app, url_for, redirect
from functools import wraps
from flask_openid import OpenID

from .. import core
from .. import admin

oid = OpenID()


def create_app(settings_override=None):
    app = core.create_app(__name__)

    if settings_override:
        app.config.from_object(settings_override)

    oid.init_app(app)
    admin.init_admin(app)

    # from .players import players_bp
    # app.register_blueprint(players_bp, url_prefix="/players")
    from .matches import matches_bp
    app.register_blueprint(matches_bp, url_prefix="/matches")
    from .players import players_bp
    app.register_blueprint(players_bp, url_prefix="/players")
    from .auth import auth_bp
    app.register_blueprint(auth_bp)

    @app.route('/')
    def redirect_to_matches():
        return redirect(url_for('matches.matches_preview'))

    return app


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
    