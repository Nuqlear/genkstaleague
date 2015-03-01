from flask import jsonify, g, Response, current_app, url_for, redirect, render_template, make_response, send_from_directory
from functools import wraps
from flask_openid import OpenID
from datetime import datetime, timedelta

from .. import core
from .. import admin
from ..models import Player, Match

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

    @app.route('/favicon.ico')
    def favicon():
        return send_from_directory(app.static_folder, 'favicon.ico')

    @app.route('/')
    def redirect_to_matches():
        return redirect(url_for('players.players'))

    @app.route('/sitemap.xml', methods=['GET'])
    def sitemap():
          """Generate sitemap.xml. Makes a list of urls and date modified."""
          pages=[]
          ten_days_ago=datetime.now() - timedelta(days=10)
          # static pages
          for rule in app.url_map.iter_rules():
            print(dir(rule))
            if "GET" in rule.methods and len(rule.arguments)==0:
                pages.append(
                    [rule.rule,ten_days_ago]
                )
          
          players = Player.query.order_by(Player.steam_id).all()
          for player in players:
              url=url_for('players.player_overview', steam_id=player.steam_id)
              pages.append([url,ten_days_ago])

          matches = Match.query.order_by(Match.id).all()
          for match in matches:
              url=url_for('matches.match', match_id=match.id)
              modified_time=datetime.fromtimestamp(match.start_time).date().isoformat()
              pages.append([url,modified_time]) 

          sitemap_xml = render_template('sitemap_template.xml', pages=pages)
          response= make_response(sitemap_xml)
          response.headers["Content-Type"] = "application/xml"    
        
          return response

    @app.context_processor
    def inject_globals():
        return {
            'GOOGLE_SITE_VERIFICATION_CODE': app.config.get('GOOGLE_SITE_VERIFICATION_CODE', None),
            'SITE_TITLE': app.config.get('SITE_TITLE', 'gleague')
        }

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
    