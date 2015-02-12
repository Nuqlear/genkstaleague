from flask import jsonify, g, Response, current_app
from functools import wraps

from .. import core


def create_app(settings_override=None):
    app = core.create_app(__name__)

    if settings_override:
        app.config.from_object(settings_override)

    for e in [401, 403, 404, 500]:
        app.errorhandler(e)(handle_error)

    from .players import players_bp
    from .matches import matches_bp
    app.register_blueprint(players_bp)
    app.register_blueprint(matches_bp)

    return app


def handle_error(e):
    msg = ''
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