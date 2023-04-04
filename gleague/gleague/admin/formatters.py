from flask import Markup
from flask import url_for

from gleague.models import Player
from gleague.models import TeamSeed


def get_url_markup(url: str, title: str) -> Markup:
    markupstring = "<a href='%s'>%s</a>" % (url, title)
    return Markup(markupstring)


def match_formatter(view, context, model, name):
    url = url_for("matches.match", match_id=model.id)
    return get_url_markup(url, model.id)


def player_formatter(view, context, model, name):
    url = url_for("players.overview", steam_id=model.steam_id)
    return get_url_markup(url, model.steam_id)


def team_seed_formatter(view, context, model, name):
    if not isinstance(model, TeamSeed):
        seed = getattr(model, name)
    else:
        seed = model
    url = url_for("matches.team_builder", seed_id=seed.id)
    return get_url_markup(url, seed.id)


def rated_by_formatter(view, context, model, name):
    return Player.query.get(model.rated_by_steam_id)
