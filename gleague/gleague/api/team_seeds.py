import datetime

from flask import current_app
from flask import Blueprint
from flask import abort
from flask import request
from flask import Response

from gleague.api import login_required
from gleague.models import TeamSeedPlayer
from gleague.core import db


team_seeds_bp = Blueprint("team_seeds", __name__)


@team_seeds_bp.route("/<seed_id>/players/<steam_id>", methods=["PUT"])
@login_required
def update_seed_player(seed_id, steam_id):
    query = TeamSeedPlayer.query
    query = query.filter(TeamSeedPlayer.seed_id == seed_id)
    query = query.filter(TeamSeedPlayer.steam_id == steam_id)
    seed_player = query.first()
    if seed_player is None:
        abort(404)
    frozen_at = (
        seed_player.seed.created_at + current_app.config["DOUBLE_DOWN_TIME"]
    )
    if frozen_at < datetime.datetime.utcnow():
        abort(400)
    data = request.json
    if "is_double_down" in data:
        if not current_app.config["DOUBLE_DOWN_ENABLED"]:
            abort(400)
        seed_player.is_double_down = data["is_double_down"]
        db.session.add(seed_player)
        db.session.commit()
    return Response(status=200)
