import os

from unittest import TestCase

from gleague import models
from gleague.core import db
from .mixin import FlaskTestCaseMixin


class GleagueTestCase(TestCase):
    def setUp(self):
        super(GleagueTestCase, self).setUp()
        db.session.rollback()
        self._create_fixtures()
        self.db_flush()

    def tearDown(self):
        super(GleagueTestCase, self).tearDown()
        db.session.rollback()

    @classmethod
    def setUpClass(cls):
        super(GleagueTestCase, cls).setUpClass()
        db.session.rollback()
        db.drop_all()
        db.create_all()
        season = models.Season()
        db.session.add(season)
        db.session.commit()
        db.session.commit()

    @classmethod
    def tearDownClass(cls):
        super(GleagueTestCase, cls).tearDownClass()
        db.session.rollback()
        db.drop_all()
        db.session.commit()

    def _create_fixtures(self):
        pass

    def db_flush(self):
        db.session.flush()


class GleagueAppTestCase(FlaskTestCaseMixin, GleagueTestCase):
    @classmethod
    def _create_app(cls):
        raise NotImplementedError

    @classmethod
    def setUpClass(cls):
        cls.app = cls._create_app()
        cls.client = cls.app.test_client()
        cls.app_context = cls.app.app_context()
        cls.app_context.push()
        super(GleagueAppTestCase, cls).setUpClass()
        db.session.commit()

    @classmethod
    def tearDownClass(cls):
        super(GleagueAppTestCase, cls).tearDownClass()
        cls.app_context.pop()
