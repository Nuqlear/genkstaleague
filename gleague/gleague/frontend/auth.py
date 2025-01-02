from flask import request
from flask import redirect
from flask import Blueprint
from flask import g
from flask import session
from flask import current_app
from pysteamsignin.steamsignin import SteamSignIn

from gleague.models import Player


auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/logout")
def logout():
    session.pop("steam_id", None)
    g.user = None
    return redirect("/")


@auth_bp.route("/login", methods=["GET"])
def login():
    if g.user is not None:
        return redirect("/")
    sl = SteamSignIn()
    if request.args.get("openid.ns"):
        returnData = request.values
        steam_id = sl.ValidateResults(returnData)
        if steam_id:
            g.user = Player.get_or_create(steam_id)
            session["steam_id"] = steam_id
            return redirect("/")
    url = request.base_url
    url = url.replace('http://', current_app.config.get("SITE_PROTOCOL") + "://")
    return sl.RedirectUser(sl.ConstructURL(url))
