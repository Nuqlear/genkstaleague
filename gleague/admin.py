from flask.ext.admin.contrib.sqla import ModelView
from flask.ext.admin import Admin, BaseView, expose, AdminIndexView
from flask import g
from flask import redirect, current_app

from .core import db
from .models import Player, Match, PlayerMatchRating, PlayerMatchStats, Season, SeasonStats


class AdminAccessMixin(object):

    def is_accessible(self):
        return g.user and g.user.steam_id in current_app.config['ADMINS_STEAM_ID']


class IndexView(AdminAccessMixin, AdminIndexView):
    pass


class BaseModelView(ModelView, AdminAccessMixin):
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
  @expose('/')
  def index(self):
    return redirect('/')


class MatchView(BaseModelView):
    column_display_pk = True

    def __init__(self, *args, **kwargs):
        super(MatchView, self).__init__(Match, *args, **kwargs)


class PlayerMatchRatingView(BaseModelView):
    can_edit = False
    column_list = ['rated_by', 'rating', 'player_match_stats']

    column_formatters = dict(rated_by=lambda v, c, m, p: Player.query.get(m.rated_by_steam_id))

    def __init__(self, *args, **kwargs):
        super(PlayerMatchRatingView, self).__init__(PlayerMatchRating, *args, **kwargs)


class PlayerMatchStatsView(BaseModelView):
    can_edit = False
    can_delete = False

    def __init__(self, *args, **kwargs):
        super(PlayerMatchStatsView, self).__init__(PlayerMatchStats, *args, **kwargs)


class SeasonView(BaseModelView):
    can_delete = False
    can_create = True

    def __init__(self, *args, **kwargs):
        super(SeasonView, self).__init__(Season, *args, **kwargs)


class SeasonStatsView(BaseModelView):

    def __init__(self, *args, **kwargs):
        super(SeasonStatsView, self).__init__(SeasonStats, *args, **kwargs)


def init_admin(app):
    admin = Admin(app, index_view=IndexView(name="Add Match"), name="genkstaADMIN")
    admin.add_view(SeasonView())
    admin.add_view(PlayerView())
    admin.add_view(SeasonStatsView())
    admin.add_view(MatchView())
    admin.add_view(PlayerMatchStatsView())
    admin.add_view(PlayerMatchRatingView())
    admin.add_view(GoToIndex(name='go to "/"'))

