from datetime import datetime, timedelta
from functools import wraps

from flask import g
from flask import Response
from flask import current_app
from flask import url_for
from flask import redirect
from flask import render_template
from flask import send_from_directory
from flask import request 
from flask import make_response 
from flask_openid import OpenID

from gleague import core
from gleague import admin
from gleague.models import Player
from gleague.models import DotaMatch

oid = OpenID()


def create_app(settings_override=None):
    app = core.create_app(__name__)
    if settings_override:
        app.config.from_object(settings_override)
    oid.init_app(app)
    admin.init_admin(app)

    from gleague.frontend.dota.matches import matches_bp as dota_matches_bp
    from gleague.frontend.dota.players import players_bp as dota_players_bp
    from gleague.frontend.dota.seasons import seasons_bp as dota_seasons_bp
    for bp in (dota_matches_bp, dota_players_bp, dota_seasons_bp):
        old_name = bp.name
        bp.name = 'dota.%s' % old_name
        url_prefix = '/%s/%s' % ('dota', old_name)
        app.register_blueprint(bp, url_prefix=url_prefix)
    from .auth import auth_bp
    app.register_blueprint(auth_bp)

    @app.route('/sitemap.xml', methods=['GET'])        
    def sitemap():        
        base_url = app.config['SITE_ADDRESS']     
        base_url = 'http://' + base_url       
        pages = []        
        ten_days_ago = datetime.now() - timedelta(days=10)        
        ten_days_ago = ten_days_ago.date().isoformat()

        pages.append([base_url+url_for('dota.seasons.players'), ten_days_ago])
        pages.append([base_url+url_for('dota.seasons.records'), ten_days_ago])
        pages.append([base_url+url_for('dota.seasons.heroes'), ten_days_ago])
        pages.append([base_url+url_for('dota.matches.matches_preview'), ten_days_ago])
      
        players = Player.query.order_by(Player.steam_id).all()        
        for player in players:        
            url = url_for('dota.players.overview', steam_id=player.steam_id)        
            pages.append([base_url+url, ten_days_ago])        
      
        matches = DotaMatch.query.order_by(DotaMatch.id).all()        
        for match in matches:     
            url = url_for('dota.matches.match', match_id=match.id)     
            modified_time = datetime.fromtimestamp(match.start_time).date().isoformat()       
            pages.append([base_url+url, modified_time])       
      
        sitemap_xml = render_template('sitemap_template.xml', pages=pages)        
        response = make_response(sitemap_xml)     
        response.headers["Content-Type"] = "application/xml"          
      
        return response

    @app.route('/favicon.ico')
    @app.route('/robots.txt')
    def favicon():
        return send_from_directory(app.static_folder, request.path[1:])

    @app.route('/')
    def redirect_to_matches():
        return redirect(url_for('dota.seasons.players'))

    @app.context_processor
    def inject_globals():
        return {
            'GOOGLE_SITE_VERIFICATION_CODE': app.config['GOOGLE_SITE_VERIFICATION_CODE'],
            'SITE_NAME': app.config['SITE_NAME'],
            'endpoint': (request.endpoint).split('.')
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
    