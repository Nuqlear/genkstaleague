import sqlalchemy

from flask import Blueprint, request, g, abort, jsonify

from .. import models
from ..core import db


players_bp = Blueprint('players', __name__)


@players_bp.route('/player/<int:steam_id>')
def player_info(steam_id):
    pass
