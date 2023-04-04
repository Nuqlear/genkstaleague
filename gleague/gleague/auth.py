from functools import wraps

from flask import g
from flask import Response


def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not g.user:
            return Response(status=401)
        return f(*args, **kwargs)
    return decorated_function


def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not g.user:
            return Response(status=401)
        if not g.user.is_admin:
            return Response(status=403)
        return f(*args, **kwargs)
    return decorated_function
