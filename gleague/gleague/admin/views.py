from flask import g
from flask import redirect
from flask import url_for
from flask_admin.contrib.sqla import ModelView
from flask_admin import BaseView
from flask_admin import expose
from flask_admin import AdminIndexView

from gleague.core import db
from gleague.models import Player
from gleague.models import Match
from gleague.models import PlayerMatchRating
from gleague.models import PlayerMatchStats
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models import TeamSeed
from gleague.models import TeamSeedPlayer
from gleague.admin.formatters import match_formatter
from gleague.admin.formatters import player_formatter
from gleague.admin.formatters import team_seed_formatter
from gleague.admin.formatters import rated_by_formatter


class AdminAccessMixin(object):
    def is_accessible(self):
        return g.user and g.user.is_admin


class IndexView(AdminAccessMixin, AdminIndexView):
    pass


class BaseModelView(AdminAccessMixin, ModelView):
    can_create = False

    def __init__(self, *args, **kwargs):
        super().__init__(self.__model__, db.session, *args, **kwargs)


class PlayerView(BaseModelView):
    __model__ = Player

    column_display_pk = True
    column_searchable_list = ["nickname"]
    column_exclude_list = ["avatar", "avatar_medium"]
    form_excluded_columns = (
        "season_stats",
        "place_1_seasons",
        "place_2_seasons",
        "place_3_seasons",
        "seeds",
    )
    column_formatters = {"steam_id": player_formatter}


class GoToIndex(BaseView):
    @expose()
    def index(self):
        return redirect("/")


class MatchView(BaseModelView):
    __model__ = Match
    column_display_pk = True
    column_exclude_list = ["team_seed", "cm_captains"]
    column_formatters = {"id": match_formatter}
    form_excluded_columns = (
        "players_stats",
        "team_seed",
        "cm_picks_bans",
    )


class SeedView(BaseModelView):
    __model__ = TeamSeed

    column_display_pk = True
    can_edit = False
    can_delete = True
    column_formatters = {"id": team_seed_formatter}


class SeedPlayerView(BaseModelView):
    __model__ = TeamSeedPlayer

    column_display_pk = False
    can_edit = True
    can_delete = False
    form_excluded_columns = ("seed",)
    column_formatters = {"seed": team_seed_formatter}


class PlayerMatchRatingView(BaseModelView):
    __model__ = PlayerMatchRating

    can_edit = False
    column_list = ["rated_by", "rating", "player_match_stats"]
    column_formatters = {"rated_by": rated_by_formatter}


class PlayerMatchStatsView(BaseModelView):
    __model__ = PlayerMatchStats

    can_edit = True
    can_delete = False
    column_searchable_list = ("match_id",)
    column_filters = ("match_id", "season_stats.player")
    form_excluded_columns = (
        "player_match_ratings",
        "player_match_items",
        "match",
        "season_stats",
    )


class SeasonView(BaseModelView):
    __model__ = Season

    can_delete = False
    can_create = True
    list_template = "/admin/season_list.html"
    form_columns = ("number", "started", "ended")

    @expose("/start_new", methods=("GET",))
    def start_new(self):
        Season.start_new()
        db.session.commit()
        return redirect(url_for("season.edit_view"))


class SeasonStatsView(BaseModelView):
    __model__ = SeasonStats

    column_filters = ("player", "season")
    form_columns = [
        "wins",
        "losses",
        "pts",
        "longest_winstreak",
        "longest_losestreak",
        "streak",
        "inactive",
    ]
