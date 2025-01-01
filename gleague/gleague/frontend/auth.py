from flask import request
from flask import redirect
from flask import Blueprint
from flask import g
from flask import session
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
    if request.args.get("openid.ns"):
        returnData = request.values
        steamLogin = SteamSignIn()
        steam_id = steamLogin.ValidateResults(returnData)
        g.user = Player.get_or_create(steam_id)
        session["steam_id"] = steam_id
        return redirect("/")
    else:
        sl = SteamSignIn()
        return sl.RedirectUser(sl.ConstructURL(request.base_url))
