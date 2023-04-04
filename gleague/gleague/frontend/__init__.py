from datetime import datetime, timedelta

from flask import make_response
from flask import redirect
from flask import render_template
from flask import request
from flask import send_from_directory
from flask import url_for
from flask_openid import OpenID

from gleague import admin
from gleague import core
from gleague.models import *

oid = OpenID()


def format_duration(duration):
    return "%02d:%02d" % (duration // 60, duration % 60)


def create_app(name=__name__):
    app = core.create_app(name)
    oid.init_app(app)
    admin.init_admin(app)

    from gleague.frontend.matches import matches_bp
    from gleague.frontend.players import players_bp
    from gleague.frontend.seasons import seasons_bp

    for bp in (matches_bp, players_bp, seasons_bp):
        app.register_blueprint(bp, url_prefix="/%s" % bp.name)
    from gleague.frontend.auth import auth_bp

    app.register_blueprint(auth_bp)
    app.jinja_env.globals.update(format_duration=format_duration)

    @app.route("/sitemap.xml", methods=["GET"])
    def sitemap():
        base_url = app.config["SITE_ADDRESS"]
        proto = app.config["SITE_PROTOCOL"].lower()
        base_url = proto + "://" + base_url
        pages = []
        ten_days_ago = datetime.now() - timedelta(days=10)
        ten_days_ago = ten_days_ago.date().isoformat()
        for page_name in [
            "seasons.players",
            "seasons.records",
            "seasons.heroes",
            "matches.matches_preview",
        ]:
            pages.append([base_url + url_for(page_name), ten_days_ago])
        players = Player.query.order_by(Player.steam_id).all()
        for player in players:
            url = url_for("players.overview", steam_id=player.steam_id)
            pages.append([base_url + url, ten_days_ago])
        matches = Match.query.order_by(Match.id).all()
        for match in matches:
            url = url_for("matches.match", match_id=match.id)
            modified_time = datetime.fromtimestamp(match.start_time).date().isoformat()
            pages.append([base_url + url, modified_time])
        sitemap_xml = render_template("sitemap_template.xml", pages=pages)
        response = make_response(sitemap_xml)
        response.headers["Content-Type"] = "application/xml"
        return response

    @app.route("/favicon.ico")
    @app.route("/robots.txt")
    def favicon():
        return send_from_directory(app.static_folder, request.path[1:])

    @app.route("/")
    def redirect_to_matches():
        return redirect(url_for("seasons.players"))

    @app.context_processor
    def inject_globals():
        return {
            "GOOGLE_SITE_VERIFICATION_CODE": app.config.get(
                "GOOGLE_SITE_VERIFICATION_CODE"
            ),
            "SITE_NAME": app.config["SITE_NAME"],
            "endpoint": request.endpoint.split("."),
        }

    return app
