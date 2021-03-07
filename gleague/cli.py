import sys
from optparse import OptionParser

from gleague import api
from gleague.core import db
from gleague import models

app = api.create_app()


def start_season():
    with app.app_context():
        models.Season.start_new()
        db.session.commit()


if __name__ == "__main__":
    commands = ['start_season']
    usage = (
        'usage: %prog [options] command \n  Possible Commands: '
        ' '.join(commands)
    )
    parser = OptionParser(usage=usage)
    (options, args) = parser.parse_args()
    if len(args) < 1:
        print('need to have at least 1 command')
        sys.exit(1)
    command = args[0]
    if command not in commands:
        print('Invalid command: %s' % command)
        print(
            'Please use one of the following commands: %s'
            % str(commands)
        )
        sys.exit(1)
    if command == commands[0]:
        start_season()
