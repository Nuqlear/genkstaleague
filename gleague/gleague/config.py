from os import environ


class BaseConfig(object):
    DEBUG = bool(environ.get('DEBUG', False))
    PROPAGATE_EXCEPTIONS = False
    TRAP_HTTP_EXCEPTIONS = False
    PRESERVE_CONTEXT_ON_EXCEPTION = False
    LOGFILE = None
    SQLALCHEMY_DATABASE_URI = environ.get('SQLALCHEMY_DATABASE_URI', 'sqlite:///')
    SECRET_KEY = environ.get('STEAM_API_KEY', 'YOUR SECRET KEY')
    STEAM_API_KEY = environ.get('STEAM_API_KEY', None)
    _admin_steam_id = int(environ.get('ADMIN_STEAM_ID', None))
    ADMINS_STEAM_ID = [_admin_steam_id] if _admin_steam_id else []
    MATCH_BASE_PTS_DIFF = 10


class gleague_api(BaseConfig):
    pass


class gleague_frontend(BaseConfig):
    SEASON_CALIBRATING_MATCHES_NUM = int(environ.get('SEASON_CALIBRATING_MATCHES_NUM', 0))
    HISTORY_MATCHES_PER_PAGE = int(environ.get('HISTORY_MATCHES_PER_PAGE', 4))
    TOP_PLAYERS_PER_PAGE = int(environ.get('TOP_PLAYERS_PER_PAGE', 22))
    PLAYER_HISTORY_MATCHES_PER_PAGE = 10
    GOOGLE_SITE_VERIFICATION_CODE = environ.get(
        'GOOGLE_SITE_VERIFICATION_CODE', 'YOUR GOGLE SITE VERIFICATION CODE'
    )
    SITE_NAME = environ.get('SITE_NAME', 'GENKSTAleague')
    SITE_ADDRESS = environ.get('SITE_ADDRESS', 'localhost')


class BaseTestingConfig(BaseConfig):
    # SQLALCHEMY_DATABASE_URI = 'postgresql://genksta:1@localhost/gleague_test'
    ADMINS_STEAM_ID = [123456789, ]


class gleague_api_tests(gleague_api, BaseTestingConfig):
    pass


class gleague_frontend_tests(gleague_frontend, BaseTestingConfig):
    pass
