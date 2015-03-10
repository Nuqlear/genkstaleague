import json

from flask import Blueprint, g, abort, current_app, render_template, request, current_app
from sqlalchemy import desc, func, and_, case

from ..models import Player, PlayerMatchStats, SeasonStats, Season
from ..core import db


seasons_bp = Blueprint('seasons', __name__)


def get_season_id(season_number):
    season = None
    if season_number == 'current':
        season = Season.current()
    else:
        season = Season.query.filter(Season.number==season_number).first()
        if not season:
            abort(404)
    return season.id


@seasons_bp.route('/current/players', methods=['GET'])
@seasons_bp.route('/<int:season_number>/players', methods=['GET'])
def players(season_number='current'):
    s_id = get_season_id(season_number)
    q = request.args.get('q')
    sort = request.args.get('sort', 'pts')
    sort_dict = {'pts':desc(SeasonStats.pts), 'nickname':func.lower(Player.nickname),
        'wins':desc(SeasonStats.wins), 'losses':desc(SeasonStats.losses)}
    page = request.args.get('page', 1)
    page = int(page)
    ss = SeasonStats.query.join(Player).group_by(Player.steam_id)\
        .filter(SeasonStats.season_id==s_id)\
        .order_by(sort_dict.get(sort, desc(SeasonStats.pts)))\
        .join(PlayerMatchStats).group_by(SeasonStats.id)\
        .having(func.count(PlayerMatchStats.id) > 3)
    if q:
        ss = ss.filter(func.lower(Player.nickname).startswith(func.lower(q)))
    ss = ss.paginate(page, current_app.config['TOP_PLAYERS_PER_PAGE'], True)
    return render_template('season_players.html', stats=ss, sort=sort)


@seasons_bp.route('/current/records', methods=['GET'])
@seasons_bp.route('/<int:season_number>/records', methods=['GET'])
def records(season_number='current'):
    s_id = get_season_id(season_number)
    win_streak_ss = db.session.query(SeasonStats).filter(and_(SeasonStats.season_id==s_id, 
        SeasonStats.longest_winstreak==func.max(SeasonStats.longest_winstreak).select())).first()
    lose_streak_ss = db.session.query(SeasonStats).filter(and_(SeasonStats.season_id==s_id, 
        SeasonStats.longest_losestreak==func.max(SeasonStats.longest_losestreak).select())).first()
    min_pts_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
            .filter(and_(SeasonStats.season_id==s_id, 
            (PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff) == 
            func.min((PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)).select()))\
            .order_by(PlayerMatchStats.id).first()
    max_pts_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
            .filter(and_(SeasonStats.season_id==s_id, 
            (PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff) == 
            func.max((PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)).select()))\
            .order_by(PlayerMatchStats.id).first()
    max_kda_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
            .filter(and_(SeasonStats.season_id==s_id, 
            ((PlayerMatchStats.kills + PlayerMatchStats.assists)/(PlayerMatchStats.deaths+1)) == 
            func.max((PlayerMatchStats.kills + PlayerMatchStats.assists)/(PlayerMatchStats.deaths+1)).select()))\
            .order_by(PlayerMatchStats.id).first()
    max_kills_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
            .filter(and_(SeasonStats.season_id==s_id, 
            PlayerMatchStats.kills == func.max(PlayerMatchStats.kills).select()))\
            .order_by(PlayerMatchStats.id).first()
    max_deaths_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
            .filter(and_(SeasonStats.season_id==s_id, 
            PlayerMatchStats.deaths == func.max(PlayerMatchStats.deaths).select()))\
            .order_by(PlayerMatchStats.id).first()
    most_lasthits_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
            .filter(and_(SeasonStats.season_id==s_id, 
            PlayerMatchStats.last_hits == func.max(PlayerMatchStats.last_hits).select()))\
            .order_by(PlayerMatchStats.id).first()
    most_herodamage_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
            .filter(and_(SeasonStats.season_id==s_id, 
            PlayerMatchStats.hero_damage == func.max(PlayerMatchStats.hero_damage).select()))\
            .order_by(PlayerMatchStats.id).first()

    in_season_most_playable = PlayerMatchStats.query.join(SeasonStats).filter(SeasonStats.season_id==s_id,)\
            .with_entities(PlayerMatchStats.hero, func.count(PlayerMatchStats.id).label('played'), 
                func.sum(case([(PlayerMatchStats.pts_diff>0, 1)], else_=0)),
                func.sum(PlayerMatchStats.pts_diff),
                func.avg(PlayerMatchStats.kills), func.avg(PlayerMatchStats.assists), 
                func.avg(PlayerMatchStats.deaths)
            ).group_by(PlayerMatchStats.hero).order_by(desc('played')).limit(3).all()

    in_season_most_profitable = PlayerMatchStats.query.join(SeasonStats).filter(SeasonStats.season_id==s_id,)\
            .with_entities(PlayerMatchStats.hero, func.count(PlayerMatchStats.id).label('played'), 
                func.sum(case([(PlayerMatchStats.pts_diff>0, 1)], else_=0)),
                func.sum(PlayerMatchStats.pts_diff).label('earned'),
                func.avg(PlayerMatchStats.kills), func.avg(PlayerMatchStats.assists), 
                func.avg(PlayerMatchStats.deaths)
            ).group_by(PlayerMatchStats.hero).order_by(desc('earned')).limit(3).all()
    
    in_season_player_records = []
    in_season_player_records.append(['Longest winstreak', win_streak_ss.player, win_streak_ss.longest_winstreak])
    in_season_player_records.append(['Longest losestreak', lose_streak_ss.player, lose_streak_ss.longest_losestreak])
    in_season_player_records.append(['Max pts ever', max_pts_pms.season_stats.player, 
        max_pts_pms.old_pts + max_pts_pms.pts_diff])
    in_season_player_records.append(['Min pts ever', min_pts_pms.season_stats.player, 
        min_pts_pms.old_pts + min_pts_pms.pts_diff])

    in_match_records = []
    in_match_records.append([max_kda_pms.match_id, 'Best KDA', max_kda_pms.season_stats.player, 
        max_kda_pms.hero, (max_kda_pms.kills + max_kda_pms.assists)/(max_kda_pms.deaths+1)])
    in_match_records.append([max_kills_pms.match_id, 'Max kills', max_kills_pms.season_stats.player, 
        max_kills_pms.hero, max_kills_pms.kills])
    in_match_records.append([max_deaths_pms.match_id, 'Max deaths', max_deaths_pms.season_stats.player, 
        max_deaths_pms.hero, max_deaths_pms.deaths])
    in_match_records.append([most_lasthits_pms.match_id, 'Most last hits', most_lasthits_pms.season_stats.player, 
        most_lasthits_pms.hero, most_lasthits_pms.last_hits])
    in_match_records.append([most_herodamage_pms.match_id, 'Most hero damage', most_herodamage_pms.season_stats.player, 
        most_herodamage_pms.hero, most_herodamage_pms.hero_damage])

    return render_template('season_records.html', in_season_player_records=in_season_player_records, in_match_records=in_match_records,
        in_season_most_playable=in_season_most_playable, in_season_most_profitable=in_season_most_profitable)
