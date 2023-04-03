from flask_admin.contrib.sqla import ModelView
from flask_admin import Admin
from flask_admin import BaseView
from flask_admin import expose
from flask_admin import AdminIndexView
from flask import g
from flask import redirect
from flask import current_app
from flask import url_for

from gleague.core import db
from gleague.models import Player
from gleague.models import Match
from gleague.models import PlayerMatchRating
from gleague.models import PlayerMatchStats
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models import TeamSeed
from gleague.models import TeamSeedPlayer


class AdminAccessMixin(object):
    def is_accessible(self):
        return (
            g.user and g.user.steam_id in current_app.config['ADMINS_STEAM_ID']
        )


class IndexView(AdminAccessMixin, AdminIndexView):
    pass


class BaseModelView(AdminAccessMixin, ModelView):
    can_create = False

    def __init__(self, model, *args, **kwargs):
        super(BaseModelView, self).__init__(model, db.session, *args, **kwargs)


class PlayerView(BaseModelView):
    column_display_pk = True
    column_searchable_list = ['nickname']
    column_exclude_list = ['avatar', 'avatar_medium']

    def __init__(self, *args, **kwargs):
        super(PlayerView, self).__init__(Player, *args, **kwargs)


class GoToIndex(BaseView):
    @expose()
    def index(self):
        return redirect('/')


class MatchView(BaseModelView):
    column_display_pk = True

    def __init__(self, *args, **kwargs):
        super(MatchView, self).__init__(Match, *args, **kwargs)


class SeedView(BaseModelView):
    column_display_pk = True
    can_edit = False
    can_delete = True

    def __init__(self, *args, **kwargs):
        super(SeedView, self).__init__(TeamSeed, *args, **kwargs)


class SeedPlayerView(BaseModelView):
    column_display_pk = False
    can_edit = True
    can_delete = False

    def __init__(self, *args, **kwargs):
        super().__init__(TeamSeedPlayer, *args, **kwargs)


class PlayerMatchRatingView(BaseModelView):
    can_edit = False
    column_list = ['rated_by', 'rating', 'player_match_stats']

    column_formatters = {
        'rated_by': lambda v, c, m, p: Player.query.get(m.rated_by_steam_id)
    }

    def __init__(self, *args, **kwargs):
        super(PlayerMatchRatingView, self).__init__(
            PlayerMatchRating, *args, **kwargs
        )


class PlayerMatchStatsView(BaseModelView):
    can_edit = True
    can_delete = False
    column_searchable_list = ("match_id",)
    column_filters = ("match_id", "season_stats.player")

    def __init__(self, *args, **kwargs):
        super(PlayerMatchStatsView, self).__init__(
            PlayerMatchStats, *args, **kwargs
        )


class SeasonView(BaseModelView):
    can_delete = False
    can_create = True
    list_template = "/admin/season_list.html"
    form_columns = ('number', 'started', 'ended')

    def __init__(self, *args, **kwargs):
        super(SeasonView, self).__init__(Season, *args, **kwargs)

    @expose('/start_new', methods=('GET',))
    def start_new(self):
        Season.start_new()
        db.session.commit()
        return redirect(url_for("season.edit_view"))


class SeasonStatsView(BaseModelView):
    column_filters = ("player", "season")
    form_columns = ['wins', 'losses', 'pts', 'longest_winstreak', 'longest_losestreak', 'streak', 'inactive']

    def __init__(self, *args, **kwargs):
        super(SeasonStatsView, self).__init__(SeasonStats, *args, **kwargs)


def init_admin(app):
    admin = Admin(
        app, index_view=IndexView(name="Add Match"), name="genkstaADMIN"
    )
    admin.add_view(PlayerView())
    admin.add_view(SeasonView())
    admin.add_view(SeasonStatsView())
    admin.add_view(MatchView())
    admin.add_view(SeedView())
    admin.add_view(SeedPlayerView())
    admin.add_view(PlayerMatchStatsView())
    admin.add_view(PlayerMatchRatingView())
    admin.add_view(GoToIndex(name='go to "/"'))
