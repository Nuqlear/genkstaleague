import datetime
from os import environ


class BaseConfig(object):
    DEBUG = bool(environ.get("DEBUG", False))
    PROPAGATE_EXCEPTIONS = False
    TRAP_HTTP_EXCEPTIONS = False
    PRESERVE_CONTEXT_ON_EXCEPTION = False
    LOGFILE = None
    SQLALCHEMY_DATABASE_URI = environ.get("SQLALCHEMY_DATABASE_URI", "sqlite:///")
    SECRET_KEY = environ.get("STEAM_API_KEY", "YOUR SECRET KEY")
    STEAM_API_KEY = environ.get("STEAM_API_KEY", None)
    MATCH_BASE_PTS_DIFF = 10
    REDIS_HOST = "redis"
    REDIS_PORT = 6379
    DOGPILE_BACKEND = "dogpile.cache.redis"
    DOGPILE_BACKEND_URL = "redis://redis:6379"
    DOGPILE_REGIONS = [("week", 3600 * 24 * 7)]

    _admin_steam_id = environ.get("ADMIN_STEAM_ID")
    _admin_steam_id = _admin_steam_id.split(",")
    _admin_steam_id = list(map(int, _admin_steam_id))
    ADMINS_STEAM_ID = _admin_steam_id
    REPLAY_PARSER_HOST = environ.get("REPLAY_PARSER_HOST", "http://dem2json:5222")
    DOUBLE_DOWN_ENABLED = environ.get("DOUBLE_DOWN_ENABLED", "1") == "1"
    DOUBLE_DOWN_TIME = datetime.timedelta(
        seconds=int(environ.get("DOUBLE_DOWN_TIME", "300"))
    )


class gleague_api(BaseConfig):
    pass


class gleague_frontend(BaseConfig):
    CACHE_ENABLED = bool(int(environ.get("CACHE_ENABLED", 0)))
    MIN_STREAK_TO_DISPLAY = int(environ.get("MIN_STREAK_TO_DISPLAY", 3))
    PLAYER_OVERVIEW_MATCHES_AMOUNT = int(
        environ.get("PlAYER_OVERVIEW_MATCHES_AMOUNT", 14)
    )
    SEASON_CALIBRATING_MATCHES_NUM = int(
        environ.get("SEASON_CALIBRATING_MATCHES_NUM", 3)
    )
    HISTORY_MATCHES_PER_PAGE = int(environ.get("HISTORY_MATCHES_PER_PAGE", 4))
    TOP_PLAYERS_PER_PAGE = int(environ.get("TOP_PLAYERS_PER_PAGE", 15))
    PLAYER_HISTORY_MATCHES_PER_PAGE = int(
        environ.get("PLAYER_HISTORY_MATCHES_PER_PAGE", 14)
    )
    GOOGLE_SITE_VERIFICATION_CODE = environ.get(
        "GOOGLE_SITE_VERIFICATION_CODE", "YOUR GOGLE SITE VERIFICATION CODE"
    )
    SITE_NAME = environ.get("SITE_NAME", "GENKSTAleague")
    SITE_ADDRESS = environ.get("SITE_ADDRESS", "localhost")
    SITE_PROTOCOL = environ.get("SITE_PROTOCOL", "HTTPS")


class BaseTestingConfig(BaseConfig):
    # SQLALCHEMY_DATABASE_URI = 'postgresql://genksta:1@localhost/gleague_test'
    ADMINS_STEAM_ID = [123456789]


class gleague_api_tests(gleague_api, BaseTestingConfig):
    pass


class gleague_frontend_tests(gleague_frontend, BaseTestingConfig):
    pass
