import sys
from optparse import OptionParser
from gleague import api
from gleague.core import db
from gleague import models

app = api.create_app()


def reinit_db():
    with app.app_context():
        db.drop_all()
        db.create_all()
        season = models.DotaSeason()
        db.session.add(season)
        db.session.commit()


if __name__ == "__main__":
    commands = ['reinit_db']
    usage = 'usage: %prog [options] command \n  Possible Commands: ' + ' '.join(
        commands)
    parser = OptionParser(usage=usage)
    (options, args) = parser.parse_args()
    if len(args) < 1:
        print('need to have at least 1 command')
        sys.exit(1)
    command = args[0]
    if not command in commands:
        print('Invalid command: %s' % command)
        print('Please use one of the following commands: %s' % str(
            commands))
        sys.exit(1)
    if command == commands[0]:
        reinit_db()
