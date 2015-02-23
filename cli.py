from gleague import api
from gleague.core import db
from gleague import models

app = api.create_app()


def init_db():
    with app.app_context():
        db.create_all()
        season = models.Season()
        db.session.add(season)
        db.session.commit()

if __name__ == "__main__":
    init_db()
