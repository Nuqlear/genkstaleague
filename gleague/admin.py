from flask.ext.admin.contrib.sqla import ModelView
from flask.ext.admin import Admin, BaseView, expose, AdminIndexView
from flask import g
from flask import redirect, current_app, url_for

from .core import db
from .models import Player, DotaMatch, DotaPlayerMatchRating, DotaPlayerMatchStats, DotaSeason, DotaSeasonStats


class AdminAccessMixin(object):

    def is_accessible(self):
        return g.user and g.user.steam_id in current_app.config['ADMINS_STEAM_ID']


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
  @expose('/')
  def index(self):
    return redirect('/')


class DotaMatchView(BaseModelView):
    column_display_pk = True

    def __init__(self, *args, **kwargs):
        super(DotaMatchView, self).__init__(DotaMatch, *args, **kwargs)


class DotaPlayerMatchRatingView(BaseModelView):
    can_edit = False
    column_list = ['rated_by', 'rating', 'player_match_stats']

    column_formatters = dict(rated_by=lambda v, c, m, p: Player.query.get(m.rated_by_steam_id))

    def __init__(self, *args, **kwargs):
        super(DotaPlayerMatchRatingView, self).__init__(DotaPlayerMatchRating, *args, **kwargs)


class DotaPlayerMatchStatsView(BaseModelView):
    can_edit = False
    can_delete = False

    def __init__(self, *args, **kwargs):
        super(DotaPlayerMatchStatsView, self).__init__(DotaPlayerMatchStats, *args, **kwargs)


class DotaSeasonView(BaseModelView):
    can_delete = False
    can_create = True
    list_template = "/admin/season_list.html"

    def __init__(self, *args, **kwargs):
        super(DotaSeasonView, self).__init__(DotaSeason, *args, **kwargs)

    @expose('/start_new', methods=('GET', ))
    def start_new(self):
        DotaSeason.start_new()
        db.session.commit()
        return redirect(url_for("DotaSeason.edit_view"))


class DotaSeasonStatsView(BaseModelView):

    def __init__(self, *args, **kwargs):
        super(DotaSeasonStatsView, self).__init__(DotaSeasonStats, *args, **kwargs)


def init_admin(app):
    admin = Admin(app, index_view=IndexView(name="Add Match"), name="genkstaADMIN")
    admin.add_view(PlayerView())
    admin.add_view(DotaSeasonView())
    admin.add_view(DotaSeasonStatsView())
    admin.add_view(DotaMatchView())
    admin.add_view(DotaPlayerMatchStatsView())
    admin.add_view(DotaPlayerMatchRatingView())
    admin.add_view(GoToIndex(name='go to "/"'))

