import collections

from flask import json


class FlaskTestCaseMixin(object):
    def _html_data(self, kwargs):
        if not kwargs.get('content_type'):
            kwargs['content_type'] = 'application/x-www-form-urlencoded'
        return kwargs

    def _json_data(self, kwargs):
        if 'data' in kwargs:
            kwargs['data'] = json.dumps(kwargs['data'])
        if not kwargs.get('content_type'):
            kwargs['content_type'] = 'application/json'
        return kwargs

    def _request(self, method, *args, **kwargs):
        return method(*args, **kwargs)

    def _jrequest(self, *args, **kwargs):
        return self._request(*args, **kwargs)

    def get(self, *args, **kwargs):
        return self._request(self.client.get, *args, **kwargs)

    def post(self, *args, **kwargs):
        return self._request(self.client.post, *args,
                              **self._html_data(kwargs))

    def put(self, *args, **kwargs):
        return self._request(self.client.put, *args, **self._html_data(kwargs))

    def delete(self, *args, **kwargs):
        return self._request(self.client.delete, *args, **kwargs)

    def jget(self, *args, **kwargs):
        return self._jrequest(self.client.get, *args, **kwargs)

    def jpost(self, *args, **kwargs):
        return self._jrequest(self.client.post, *args,
                              **self._json_data(kwargs))

    def jput(self, *args, **kwargs):
        return self._jrequest(self.client.put, *args,
                              **self._json_data(kwargs))

    def jdelete(self, *args, **kwargs):
        return self._jrequest(self.client.delete, *args, **kwargs)

    def assertStatusCode(self, response, status_code):
        self.assertEquals(status_code, response.status_code)
        return response

    def assertOk(self, response):
        return self.assertStatusCode(response, 200)

    def assertBadRequest(self, response):
        return self.assertStatusCode(response, 400)

    def assertForbidden(self, response):
        return self.assertStatusCode(response, 403)

    def assertNotFound(self, response):
        return self.assertStatusCode(response, 404)

    def assertLength(self, lenght, seq):
        return self.assertEqual(lenght, len(seq))

    def assertElementsEqual(self, L1, L2):
        return len(L1) == len(L2) and sorted(L1) == sorted(L2)
