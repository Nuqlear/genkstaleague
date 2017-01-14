# genkstaleague
__genkstaleague__ is a simple web-application for keeping statistics of private Dota2 fun-leagues. Fun prefix there means that it is unsuitable for big serious leagues because adding result of the played game requires manual uploading its replay file through website's admin-panel.
## Why manual uploading and not using bot/dota2 api
- Information about private lobby games is not accessible through the Dota2 api if they are not attached to any official league. 
- Bot developing is a complicated task while performance of the my cubian-based (cubian is a raspberry pi analogue) server is not so great.
  
## Dependencies
I am storing data in PostgreSQL but you probably can use any sqlalchemy-supported database.  
Replay parsing is written in Go and utilizes [Dotabuff's Manta](https://github.com/dotabuff/manta).  
Frontend dependencies are managed by Bower and listed in `/frontend/static/lib/bower.json`  
Other dependencies are python3-specific and written in requirements.txt
## How to run it

```
cd dem2json
go get github.com/dotabuff/manta
go build dem2json.go heroes.go parser.go
cd ../gleague
cp config.py.example config.py
vi config.py
cd ../gleague/frontend/static/lib
bower install
cd ../../../../..
pip install -r requirements.txt
python wsgi.py
```