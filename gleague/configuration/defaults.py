from os import environ


class BaseConfig(object):
    SQLALCHEMY_DATABASE_URI = 'sqlite:///'
    DEBUG = False
    PROPAGATE_EXCEPTIONS = False
    TRAP_HTTP_EXCEPTIONS = False
    PRESERVE_CONTEXT_ON_EXCEPTION = False
    SECRET_KEY = 'YOUR SECRET KEY'
    LOGFILE = None
    STEAM_API_KEY = environ.get('STEAM_API_KEY', None)
    ADMINS_STEAM_ID = []
    MATCH_BASE_PTS_DIFF = 10


class gleague_api(BaseConfig):
    pass


class gleague_frontend(BaseConfig):
    SEASON_CALIBRATING_MATCHES_NUM = 3
    HISTORY_MATCHES_PER_PAGE = 4
    TOP_PLAYERS_PER_PAGE = 22
    GOOGLE_SITE_VERIFICATION_CODE = 'YOUR GOGLE SITE VERIFICATION CODE'
    PLAYER_HISTORY_MATCHES_PER_PAGE = 10
    SITE_NAME = 'GENKSTAleague'
    SITE_ADDRESS = 'localhost'


class BaseTestingConfig(BaseConfig):
    SQLALCHEMY_DATABASE_URI = 'postgresql://genksta:1@localhost/gleague_test'
    ADMINS_STEAM_ID = [123456789, ]    


class gleague_api_tests(gleague_api, BaseTestingConfig):
    pass


class gleague_frontend_tests(gleague_frontend, BaseTestingConfig):
    pass
