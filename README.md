# genkstaleague
__genkstaleague__ is a web-application for keeping statistics of Dota2 private lobby games. It was made to organize some sort of league among friends and friends of friends.

Technically it is very simple and is unsuitable for something serious, because adding a result of the played game is not done automatically and requires manual uploading its replay file through website's admin-panel.
## Why manual uploading and not using bot/dota2 api
- Information about private lobby games is not accessible through the Dota2 api if they are not attached to any official league.
- Bot developing is a difficult task while performance of the my cubian-based (cubian is a raspberry pi analogue) server is not so great.


## How to run it
- Add STEAM_API_KEY to .env file
- Build docker images:  
  `docker-compose -f docker-compose.yml -f docker-compose.build.yml build`
- Run docker-compose with either dev or prod setup:
  - `docker-compose -f docker-compose.yml -f docker-compose.dev.yml up`
  - `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up`
- Create tables in the database:  
  `docker-compose -f docker-compose.yml -f docker-compose.prod.yml exec gleague python cli.py reinit_db`

I guess it should be possible to run the project without Docker too, but i am not doing it and so will not cover such way here.

## Credits
Thanks to [Dotabuff](https://github.com/dotabuff) for open sourcing [Manta](https://github.com/dotabuff/manta), what made replay parsing possible.
