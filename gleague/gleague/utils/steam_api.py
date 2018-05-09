import json
from urllib.request import urlopen

from werkzeug import url_encode


def get_steam_user_info(steam_id, steam_api_key):
    options = {
        'key': steam_api_key,
        'steamids': steam_id
    }
    url = 'http://api.steampowered.com/ISteamUser/' \
          'GetPlayerSummaries/v0001/?%s' % url_encode(options)
    rv = json.loads(urlopen(url).read().decode())
    return rv['response']['players']['player'][0] or {}


def get_dota2_heroes(steam_api_key):
    options = {
        'key': steam_api_key,
    }
    url = 'http://api.steampowered.com/IEconDOTA2_570/' \
          'GetHeroes/V1/?%s' % url_encode(options)
    res = json.loads(urlopen(url).read().decode('utf-8'))
    d = dict()
    for i in res['result']['heroes']:
        d[i['id']] = i['name']
    return d
