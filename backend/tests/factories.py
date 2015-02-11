from factory import Factory, Sequence
from factory.alchemy import SQLAlchemyModelFactory

from gleague.core import db
from gleague import models


class Factory(SQLAlchemyModelFactory):
    FACTORY_SESSION = db.session


class PlayerFactory(Factory):
    FACTORY_FOR = models.Player

    steam_id = Sequence(lambda n: n)
    nickname = Sequence(lambda n: 'Player #%s' % n)


class SeasonFactory(Factory):
    FACTORY_FOR = models.Season

    id = Sequence(lambda n: n)
    number = Sequence(lambda n: n)
