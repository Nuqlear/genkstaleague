from unittest import TestCase
from unittest import mock

from gleague.core import db
from tests.mixin import FlaskTestCaseMixin
from tests.factories import SeasonFactory


class GleagueTestCase(TestCase):
    def setUp(self):
        super(GleagueTestCase, self).setUp()
        self.season = SeasonFactory()
        db.session.flush()
        self.patches = [
            mock.patch('gleague.core.db.session.commit', side_effect=None), 
            mock.patch('gleague.core.db.session.remove', side_effect=None)
        ]
        for patch in self.patches:
            patch.start()

    def tearDown(self):
        super(GleagueTestCase, self).tearDown()
        db.session.rollback()
        db.session.expunge_all()
        for patch in self.patches:
            patch.stop()

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
