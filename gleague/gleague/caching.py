from functools import wraps, partial
from collections import defaultdict

from flask import _app_ctx_stack
from dogpile.cache import make_region
from dogpile.cache.util import kwarg_function_key_generator
from dogpile.cache.util import sha1_mangle_key


class parametrized_defaultdict(defaultdict):
    def __missing__(self, key):
        if self.default_factory is None:
            raise KeyError(key)
        else:
            ret = self[key] = self.default_factory(key)
            return ret


class DogpileCache:
    ATTR_PREFIX = "_dogpile_cache"
    CTX_REGIONS_ATTR = "%s_regions" % ATTR_PREFIX
    CTX_DECORATORS_ATTR = "%s_decorators" % ATTR_PREFIX
    FUNC_REGION_ATTR = "%s_region" % ATTR_PREFIX
    FUNC_INVALIDATE_ATTR = "invalidate"

    def __init__(self, app=None):
        if app is not None:
            self.init_app(app)

    def init_app(self, app):
        self.app = app
        if not hasattr(app, "extensions"):
            app.extensions = {}
        app.extensions["dogpile_cache"] = self
        app.config.setdefault("DOGPILE_BACKEND", "dogpile.cache.redis")
        app.config.setdefault("DOGPILE_BACKEND_URL", "localhost:3679")
        app.config.setdefault("DOGPILE_REGIONS", [("default", 3600)])

    def _create_regions(self):
        backend = self.app.config["DOGPILE_BACKEND"]
        backend_url = self.app.config["DOGPILE_BACKEND_URL"]
        regions = {}
        for name, expiration in self.app.config["DOGPILE_REGIONS"]:
            region = make_region(
                name=name,
                function_key_generator=kwarg_function_key_generator,
                key_mangler=lambda key: sha1_mangle_key(key.encode("utf-8")),
            ).configure(
                backend=backend,
                expiration_time=int(expiration),
                arguments={"url": backend_url},
            )
            regions[name] = region
        return regions

    @property
    def regions(self):
        ctx = _app_ctx_stack.top
        if ctx is not None:
            regions = getattr(ctx, self.CTX_REGIONS_ATTR, None)
            if regions is None:
                regions = self._create_regions()
                setattr(ctx, self.CTX_REGIONS_ATTR, regions)
            return regions

    def get_decorator(self, region_name, function):
        ctx = _app_ctx_stack.top
        if ctx is not None:
            if region_name in self.regions:
                if not hasattr(ctx, self.CTX_DECORATORS_ATTR):
                    decorators = {
                        key: parametrized_defaultdict(
                            lambda fn, region=value: region.cache_on_arguments()(fn)
                        )
                        for key, value in self.regions.items()
                    }
                    setattr(ctx, self.CTX_DECORATORS_ATTR, decorators)
                else:
                    decorators = getattr(ctx, self.CTX_DECORATORS_ATTR)
                return decorators[region_name][function]
            else:
                raise KeyError('You didn\'t specified region "%s"' % region_name)

    def cache_on_arguments(self, region_name):
        def decorator(func):
            setattr(func, self.FUNC_REGION_ATTR, region_name)
            setattr(
                func,
                self.FUNC_INVALIDATE_ATTR,
                partial(self.invalidate, region_name, func),
            )

            @wraps(func)
            def wrapper(*args, **kwargs):
                cache_decorator = self.get_decorator(region_name, func)
                return cache_decorator(*args, **kwargs)

            return wrapper

        return decorator

    def invalidate(self, region_name, function, *args):
        return self.get_decorator(region_name, function).invalidate(*args)
