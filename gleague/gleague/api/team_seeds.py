import datetime

from flask import current_app
from flask import Blueprint
from flask import abort
from flask import request
from flask import Response
from flask import jsonify

from gleague.auth import login_required
from gleague.models import TeamSeedPlayer
from gleague.core import db
from gleague.core import cache


team_seeds_bp = Blueprint("team_seeds", __name__)


@team_seeds_bp.route("/<seed_id>/players", methods=["GET"])
@login_required
@cache.cache_on_arguments("week")
def get_seed_players(seed_id):
    query = TeamSeedPlayer.query
    query = query.filter(TeamSeedPlayer.seed_id == seed_id)
    team_seed_players = query.all()
    team_seed_players = [
        {
            "steam_id": str(tsp.steam_id),
            "is_radiant": tsp.is_radiant,
            "is_double_down": tsp.is_double_down,
        }
        for tsp in team_seed_players
    ]
    return jsonify({"team_seed_players": team_seed_players})


@team_seeds_bp.route("/<seed_id>/players/<int:steam_id>", methods=["PUT"])
@login_required
def update_seed_player(seed_id, steam_id):
    query = TeamSeedPlayer.query
    query = query.filter(TeamSeedPlayer.seed_id == seed_id)
    query = query.filter(TeamSeedPlayer.steam_id == steam_id)
    seed_player = query.first()
    if seed_player is None:
        abort(404)
    frozen_at = seed_player.seed.created_at + current_app.config["DOUBLE_DOWN_TIME"]
    if frozen_at < datetime.datetime.utcnow():
        abort(400)
    data = request.json
    if "is_double_down" in data:
        if not current_app.config["DOUBLE_DOWN_ENABLED"]:
            abort(400)
        seed_player.is_double_down = data["is_double_down"]
        db.session.add(seed_player)
        db.session.commit()
        get_seed_players.invalidate(seed_id)
    return Response(status=200)
