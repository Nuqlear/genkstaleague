from flask_admin import Admin

from gleague.admin.views import IndexView
from gleague.admin.views import PlayerView
from gleague.admin.views import SeasonView
from gleague.admin.views import SeasonStatsView
from gleague.admin.views import MatchView
from gleague.admin.views import SeedView
from gleague.admin.views import SeedPlayerView
from gleague.admin.views import PlayerMatchStatsView
from gleague.admin.views import PlayerMatchRatingView
from gleague.admin.views import GoToIndex


def init_admin(app):
    admin = Admin(
        app, index_view=IndexView(name="Add Match"), name="genkstaleague admin"
    )
    for klass in [
        PlayerView,
        SeasonView,
        SeasonStatsView,
        MatchView,
        SeedView,
        SeedPlayerView,
        PlayerMatchStatsView,
        PlayerMatchRatingView,
    ]:
        admin.add_view(klass())
    admin.add_view(GoToIndex(name='go to "/"'))
