from .. import core
from .views import init_admin


def create_app(settings_override=None):
    app = core.create_app(__name__)

    if settings_override:
        app.config.from_object(settings_override)

    init_admin(app)
    return app
