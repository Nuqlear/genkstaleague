from functools import wraps

import pyssdb
from sqlalchemy import event
from flask import request
from flask import render_template_string

from gleague import models


class SSDBCache(object):

    dependents = {models.Match: set(), models.PlayerMatchRating: set()}

    @staticmethod
    def cache_aware(block, bypass_cache=False):
        if bypass_cache:
            return render_template_string(block)
        else:
            return block

    def init_app(self, app):
        self.client = pyssdb.Client(
            host=app.config["SSDB_HOST"], port=app.config["SSDB_PORT"]
        )
        app.jinja_env.globals.update(cache_aware=self.cache_aware)

    def get(self, base, key):
        return self.client.hget(base, key)

    def set(self, base, key, value):
        self.client.hset(base, key, value)

    def clear(self, key):
        for dep in self.dependents[key]:
            self.client.hclear(dep)


cache = SSDBCache()


def cached(dependencies):
    def decorator(f):
        base = f"{f.__module__}.{f.__name__}"
        for dependency in dependencies:
            cache.dependents[dependency].add(base)

        @wraps(f)
        def decorated_function(*args, **kwargs):
            key = f"{request.path}?{request.query_string}"
            res = cache.get(base, key)
            if not res:
                res = f(*args, **kwargs)
                cache.set(base, key, res)
            else:
                res = res.decode("utf-8")
            return render_template_string(res)

        return decorated_function

    return decorator


@event.listens_for(models.Match, "after_update", propagate=True)
@event.listens_for(models.Match, "after_insert", propagate=True)
def clear_cache_match(mapper, connection, target):
    cache.clear(models.Match)


@event.listens_for(models.PlayerMatchRating, "after_update", propagate=True)
@event.listens_for(models.PlayerMatchRating, "after_insert", propagate=True)
def clear_cache_rating(mapper, connection, target):
    cache.clear(models.PlayerMatchRating)
