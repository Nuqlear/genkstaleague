import json

from flask import Blueprint
from flask import g
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import desc
from sqlalchemy import func
from sqlalchemy import and_
from sqlalchemy import case

from gleague.models import Player
from gleague.models import DotaPlayerMatchStats
from gleague.models import DotaSeasonStats
from gleague.models import DotaSeason
from gleague.models import DotaMatch
from gleague.core import db


seasons_bp = Blueprint('seasons', __name__)


def get_season_id(season_number):
    season = None
    if season_number == -1:
        season = DotaSeason.current()
    else:
        season = DotaSeason.query.filter(DotaSeason.number==season_number).first()
        if not season:
            abort(404)
    return season.number, season.id


@seasons_bp.route('/current/players', methods=['GET'])
@seasons_bp.route('/<int:season_number>/players', methods=['GET'])
def players(season_number=-1):
    season_number, s_id = get_season_id(season_number)
    q = request.args.get('q')
    sort = request.args.get('sort', 'pts')
    sort_dict = {'pts':desc(DotaSeasonStats.pts), 'nickname':func.lower(Player.nickname),
        'wins':desc(DotaSeasonStats.wins), 'losses':desc(DotaSeasonStats.losses)}
    page = request.args.get('page', 1)
    page = int(page)
    ss = DotaSeasonStats.query.join(Player).group_by(Player.steam_id)\
        .filter(DotaSeasonStats.season_id==s_id)\
        .order_by(sort_dict.get(sort, desc(DotaSeasonStats.pts)))\
        .join(DotaPlayerMatchStats).group_by(DotaSeasonStats.id)\
        .having(func.count(DotaPlayerMatchStats.id) > current_app.config['SEASON_CALIBRATING_MATCHES_NUM'])
    if q:
        ss = ss.filter(func.lower(Player.nickname).startswith(func.lower(q)))
    ss = ss.paginate(page, current_app.config['TOP_PLAYERS_PER_PAGE'], True)

    seasons = [e[0] for e in db.session.query(DotaSeason.number).all()]

    return render_template('dota/season_players.html', stats=ss, sort=sort, seasons=seasons, season_number=season_number)


@seasons_bp.route('/current/records', methods=['GET'])
@seasons_bp.route('/<int:season_number>/records', methods=['GET'])
def records(season_number=-1):
    season_number, s_id = get_season_id(season_number)

    subq = (DotaMatch.query.join(DotaSeason)
        .filter(DotaSeason.id == s_id)
        .with_entities(func.max(DotaMatch.duration)).as_scalar())
    longest_match = DotaMatch.query.filter(and_(DotaMatch.duration==subq), 
        DotaMatch.season_id==s_id).first()

    seasons = [e[0] for e in db.session.query(DotaSeason.number).all()]
    _kwargs = {'longest_match': longest_match, 'season_number':season_number, 'seasons':seasons}

    if longest_match:
        subq = (DotaSeasonStats.query
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaSeasonStats.longest_winstreak)).as_scalar())
        win_streak_ss = db.session.query(DotaSeasonStats).filter(and_(DotaSeasonStats.season_id==s_id, 
            DotaSeasonStats.longest_winstreak==subq)).first()

        subq = (DotaSeasonStats.query
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaSeasonStats.longest_losestreak)).as_scalar())
        lose_streak_ss = db.session.query(DotaSeasonStats).filter(and_(DotaSeasonStats.season_id==s_id, 
            DotaSeasonStats.longest_losestreak==subq)).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.min(DotaPlayerMatchStats.old_pts + DotaPlayerMatchStats.pts_diff)).as_scalar())
        min_pts_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                (DotaPlayerMatchStats.old_pts + DotaPlayerMatchStats.pts_diff) == 
                subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaPlayerMatchStats.old_pts + DotaPlayerMatchStats.pts_diff)).as_scalar())
        max_pts_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                (DotaPlayerMatchStats.old_pts + DotaPlayerMatchStats.pts_diff) == 
                subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max((DotaPlayerMatchStats.kills + DotaPlayerMatchStats.assists)/(DotaPlayerMatchStats.deaths+1))).as_scalar())
        max_kda_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                ((DotaPlayerMatchStats.kills + DotaPlayerMatchStats.assists)/(DotaPlayerMatchStats.deaths+1)) == 
                subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaPlayerMatchStats.kills)).as_scalar())
        max_kills_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                DotaPlayerMatchStats.kills == subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaPlayerMatchStats.deaths)).as_scalar())
        max_deaths_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                DotaPlayerMatchStats.deaths == subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaPlayerMatchStats.last_hits)).as_scalar())
        most_lasthits_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                DotaPlayerMatchStats.last_hits == subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaPlayerMatchStats.hero_damage)).as_scalar())
        most_herodamage_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                DotaPlayerMatchStats.hero_damage == subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaPlayerMatchStats.tower_damage)).as_scalar())
        most_towerdamage_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                DotaPlayerMatchStats.tower_damage == subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        subq = (DotaPlayerMatchStats.query.join(DotaSeasonStats)
            .filter(DotaSeasonStats.season_id == s_id)
            .with_entities(func.max(DotaPlayerMatchStats.damage_taken)).as_scalar())
        most_damagetaken_pms = db.session.query(DotaPlayerMatchStats).join(DotaSeasonStats)\
                .filter(and_(DotaSeasonStats.season_id==s_id, 
                DotaPlayerMatchStats.damage_taken == subq))\
                .order_by(DotaPlayerMatchStats.id).first()

        in_season_player_records = []
        in_match_records = []

        in_season_player_records.append(['Longest winstreak', win_streak_ss.player, win_streak_ss.longest_winstreak])
        in_season_player_records.append(['Longest losestreak', lose_streak_ss.player, lose_streak_ss.longest_losestreak])
        in_season_player_records.append(['Max pts ever', max_pts_pms.season_stats.player, 
            max_pts_pms.old_pts + max_pts_pms.pts_diff])
        in_season_player_records.append(['Min pts ever', min_pts_pms.season_stats.player, 
            min_pts_pms.old_pts + min_pts_pms.pts_diff])
        in_match_records.append([max_kda_pms.match_id, 'Best KDA', max_kda_pms.season_stats.player, 
            max_kda_pms.hero, (max_kda_pms.kills + max_kda_pms.assists)/(max_kda_pms.deaths+1)])
        in_match_records.append([max_kills_pms.match_id, 'Max kills', max_kills_pms.season_stats.player, 
            max_kills_pms.hero, max_kills_pms.kills])
        in_match_records.append([max_deaths_pms.match_id, 'Max deaths', max_deaths_pms.season_stats.player, 
            max_deaths_pms.hero, max_deaths_pms.deaths])
        in_match_records.append([most_lasthits_pms.match_id, 'Most last hits', most_lasthits_pms.season_stats.player, 
            most_lasthits_pms.hero, most_lasthits_pms.last_hits])
        if most_herodamage_pms:
            in_match_records.append([most_herodamage_pms.match_id,
                                     'Most hero damage',
                                     most_herodamage_pms.season_stats.player,
                                     most_herodamage_pms.hero,
                                    most_herodamage_pms.hero_damage])
        if most_towerdamage_pms:
            in_match_records.append([most_towerdamage_pms.match_id,
                                     'Most tower damage',
                                     most_towerdamage_pms.season_stats.player,
                                     most_towerdamage_pms.hero,
                                     most_towerdamage_pms.tower_damage])
        if most_damagetaken_pms:
            in_match_records.append([most_damagetaken_pms.match_id,
                                     'Most damage taken',
                                     most_damagetaken_pms.season_stats.player,
                                     most_damagetaken_pms.hero, most_damagetaken_pms.damage_taken])

        subq = (DotaMatch.query.join(DotaSeason)
            .filter(DotaSeason.id == s_id)
            .with_entities(func.min(DotaMatch.duration)).as_scalar())
        shortest_match = DotaMatch.query.filter(and_(DotaMatch.duration==subq), 
            DotaMatch.season_id==s_id).first()

        avg_match_duration = (DotaMatch.query.join(DotaSeason)
            .filter(DotaSeason.id == s_id)
            .with_entities(func.avg(DotaMatch.duration)).first())
        avg_match_duration = avg_match_duration[0] if avg_match_duration else None

        radiant_winrate = (100 * func.sum(case([(DotaMatch.radiant_win==True, 1)], else_=0))/
                            func.count(DotaMatch.id))
        dire_winrate = (100 * func.sum(case([(DotaMatch.radiant_win==False, 1)], else_=0))/
                            func.count(DotaMatch.id))
        side_winrates = (DotaMatch.query.join(DotaSeason)
            .filter(DotaSeason.id == s_id)
            .with_entities(radiant_winrate, dire_winrate).first())

        _kwargs = dict(in_season_player_records=in_season_player_records, 
            in_match_records=in_match_records, longest_match=longest_match, 
            shortest_match=shortest_match, seasons=seasons, 
            season_number=season_number, avg_match_duration=avg_match_duration,
            side_winrates=side_winrates)

    return render_template('dota/season_records.html', **_kwargs)


@seasons_bp.route('/current/heroes', methods=['GET'])
@seasons_bp.route('/<int:season_number>/heroes', methods=['GET'])
def heroes(season_number=-1):
    season_number, s_id = get_season_id(season_number)
    _sort = request.args.get('sort', 'played')
    if _sort not in ['hero', 'played', 'pts_diff', 'winrate', 'kda']:
        _sort = 'played'
    order_by = _sort
    _desc = request.args.get('desc', 'yes')
    if _desc != 'no':
        _desc = 'yes'
        order_by = desc(order_by)
    hero_filter = request.args.get('hero', None)
    in_season_heroes = DotaPlayerMatchStats.query.join(DotaSeasonStats).filter(DotaSeasonStats.season_id==s_id)\
            .with_entities(DotaPlayerMatchStats.hero, func.count(DotaPlayerMatchStats.id).label('played'), 
                (100 * func.sum(case([(DotaPlayerMatchStats.pts_diff>0, 1)], else_=0))/func.count(DotaPlayerMatchStats.id)).label('winrate'),
                func.sum(DotaPlayerMatchStats.pts_diff).label('pts_diff'),
                ((func.avg(DotaPlayerMatchStats.kills) + func.avg(DotaPlayerMatchStats.assists))/
                    func.avg(DotaPlayerMatchStats.deaths+1)).label('kda'), 
            ).group_by(DotaPlayerMatchStats.hero).order_by(order_by).all()

    seasons = [e[0] for e in db.session.query(DotaSeason.number).all()]

    return render_template('dota/season_heroes.html', in_season_heroes=in_season_heroes, sort=_sort, _desc=desc, seasons=seasons, 
        season_number=season_number)
