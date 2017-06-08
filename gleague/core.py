import logging
import logging.handlers
import os

from flask import Flask
from flask import session
from flask import g
from flask import request
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class FlaskApp(Flask):
    def log_exception(self, exc_info):
        user = ''
        if g.user:
            user = g.user.__repr__()
        self.logger.error('[%s] %s %s Exception on ' % (user,
                                                        request.method,
                                                        request.path), exc_info=exc_info)


def setup_logging(app):
    fmt = '[%(filename)s:%(lineno)d] ' if app.debug else '%(module)-12s '
    fmt += '%(asctime)s %(levelname)-7s %(message)s'
    datefmt = '%Y-%m-%d %H:%M:%S'
    loglevel = logging.DEBUG if app.debug else logging.INFO
    formatter = logging.Formatter(fmt=fmt, datefmt=datefmt)

    if app.config['LOGFILE']:
        app.logger.debug("doing file logging to %s" % app.config['LOGFILE'])
        file_handler = logging.handlers.RotatingFileHandler(app.config['LOGFILE'], 
                                                            maxBytes=500000,
                                                            backupCount=5)
        file_handler.setLevel(loglevel)
        file_handler.setFormatter(formatter)
        app.logger.addHandler(file_handler)


def reg_gl_vars(app):
    from .models import Player

    @app.before_request
    def guser():
        g.user = None
        session.permanent = True
        if 'steam_id' in session:
            if session['steam_id']:
                user = Player.query.get(session['steam_id'])
                if user:
                    g.user = user
                else:
                    session.pop('steam_id')


def reg_rollback_on_exc(app):
    @app.teardown_request
    def _manage_transaction(exception):
        if not exception:
            db.session.commit()
        db.session.remove()


def create_app(name):
    app = FlaskApp(name, instance_relative_config=True)
    cfg_class = name.replace('.', '_')
    app.config.from_object('gleague.configuration.defaults.%s' % cfg_class)
    try:
        app.config.from_object('gleague.configuration.customs.%s' % cfg_class)
    except ImportError:
        pass
    frontend_folder = os.path.join(os.path.dirname(__file__), 'frontend')
    app.template_folder = os.path.join(frontend_folder, 'templates')
    app.static_folder = os.path.join(frontend_folder, 'static')
    setup_logging(app)
    reg_gl_vars(app)
    db.init_app(app)
    reg_rollback_on_exc(app)
    return app
