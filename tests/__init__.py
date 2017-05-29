from unittest import TestCase

from gleague.core import db
from tests.mixin import FlaskTestCaseMixin
from tests.factories.dota import SeasonFactory


class GleagueTestCase(TestCase):
    def setUp(self):
        super(GleagueTestCase, self).setUp()
        self.season = SeasonFactory()
        db.session.flush()

    def tearDown(self):
        super(GleagueTestCase, self).tearDown()
        db.session.rollback()
        db.session.expunge_all()

    @classmethod
    def setUpClass(cls):
        super(GleagueTestCase, cls).setUpClass()
        db.drop_all()
        db.create_all()
        db.session.commit()

    @classmethod
    def tearDownClass(cls):
        super(GleagueTestCase, cls).tearDownClass()
        db.session.rollback()
        db.drop_all()
        db.session.commit()

    def _create_fixtures(self):
        pass

    def set_user(self, steam_id):
        with self.client.session_transaction() as session:
            session['steam_id'] = steam_id


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
