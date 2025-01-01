from flask import jsonify

from gleague import core
from gleague import admin


def create_app(name=__name__):
    app = core.create_app(name)
    for e in [401, 403, 404, 500]:
        app.errorhandler(e)(handle_error)
    admin.init_admin(app)
    from gleague.api.matches import matches_bp
    from gleague.api.team_seeds import team_seeds_bp
    app.register_blueprint(matches_bp, url_prefix='/matches')
    app.register_blueprint(team_seeds_bp, url_prefix='/team_seeds')
    return app


def handle_error(e):
    msg = 'Not Found'
    code = 500
    if hasattr(e, 'msg'):
        msg = e.msg
    if hasattr(e, 'code'):
        code = e.code
    return jsonify({'error': msg}), code
