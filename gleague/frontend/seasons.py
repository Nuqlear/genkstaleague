import json

from flask import Blueprint, g, abort, current_app, render_template, request, current_app
from sqlalchemy import desc, func, and_, case

from ..models import Player, PlayerMatchStats, SeasonStats, Season, Match
from ..core import db


seasons_bp = Blueprint('seasons', __name__)


def get_season_id(season_number):
    season = None
    if season_number == -1:
        season = Season.current()
    else:
        season = Season.query.filter(Season.number==season_number).first()
        if not season:
            abort(404)
    return season.number, season.id


@seasons_bp.route('/current/players', methods=['GET'])
@seasons_bp.route('/<int:season_number>/players', methods=['GET'])
def players(season_number=-1):
    season_number, s_id = get_season_id(season_number)
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
        .having(func.count(PlayerMatchStats.id) > current_app.config['SEASON_CALIBRATING_MATCHES_NUM'])
    if q:
        ss = ss.filter(func.lower(Player.nickname).startswith(func.lower(q)))
    ss = ss.paginate(page, current_app.config['TOP_PLAYERS_PER_PAGE'], True)

    seasons = [e[0] for e in db.session.query(Season.number).all()]

    return render_template('season_players.html', stats=ss, sort=sort, seasons=seasons, season_number=season_number)


@seasons_bp.route('/current/records', methods=['GET'])
@seasons_bp.route('/<int:season_number>/records', methods=['GET'])
def records(season_number=-1):
    season_number, s_id = get_season_id(season_number)

    subq = (Match.query.join(Season)
        .filter(Season.id == s_id)
        .with_entities(func.max(Match.duration)).as_scalar())
    longest_match = Match.query.filter(and_(Match.duration==subq), 
        Match.season_id==s_id).first()

    _args = {'longest_match': longest_match}

    if longest_match:
        subq = (SeasonStats.query
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(SeasonStats.longest_winstreak)).as_scalar())
        win_streak_ss = db.session.query(SeasonStats).filter(and_(SeasonStats.season_id==s_id, 
            SeasonStats.longest_winstreak==subq)).first()

        subq = (SeasonStats.query
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(SeasonStats.longest_losestreak)).as_scalar())
        lose_streak_ss = db.session.query(SeasonStats).filter(and_(SeasonStats.season_id==s_id, 
            SeasonStats.longest_losestreak==subq)).first()

        subq = (PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.min(PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)).as_scalar())
        min_pts_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
                .filter(and_(SeasonStats.season_id==s_id, 
                (PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff) == 
                subq))\
                .order_by(PlayerMatchStats.id).first()

        subq = (PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)).as_scalar())
        max_pts_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
                .filter(and_(SeasonStats.season_id==s_id, 
                (PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff) == 
                subq))\
                .order_by(PlayerMatchStats.id).first()

        subq = (PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max((PlayerMatchStats.kills + PlayerMatchStats.assists)/(PlayerMatchStats.deaths+1))).as_scalar())
        max_kda_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
                .filter(and_(SeasonStats.season_id==s_id, 
                ((PlayerMatchStats.kills + PlayerMatchStats.assists)/(PlayerMatchStats.deaths+1)) == 
                subq))\
                .order_by(PlayerMatchStats.id).first()

        subq = (PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.kills)).as_scalar())
        max_kills_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
                .filter(and_(SeasonStats.season_id==s_id, 
                PlayerMatchStats.kills == subq))\
                .order_by(PlayerMatchStats.id).first()

        subq = (PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.deaths)).as_scalar())
        max_deaths_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
                .filter(and_(SeasonStats.season_id==s_id, 
                PlayerMatchStats.deaths == subq))\
                .order_by(PlayerMatchStats.id).first()

        subq = (PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.last_hits)).as_scalar())
        most_lasthits_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
                .filter(and_(SeasonStats.season_id==s_id, 
                PlayerMatchStats.last_hits == subq))\
                .order_by(PlayerMatchStats.id).first()

        subq = (PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.hero_damage)).as_scalar())
        most_herodamage_pms = db.session.query(PlayerMatchStats).join(SeasonStats)\
                .filter(and_(SeasonStats.season_id==s_id, 
                PlayerMatchStats.hero_damage == subq))\
                .order_by(PlayerMatchStats.id).first()
        
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
        in_match_records.append([most_herodamage_pms.match_id, 'Most hero damage', most_herodamage_pms.season_stats.player, 
            most_herodamage_pms.hero, most_herodamage_pms.hero_damage])

        subq = (Match.query.join(Season)
            .filter(Season.id == s_id)
            .with_entities(func.min(Match.duration)).as_scalar())
        shortest_match = Match.query.filter(and_(Match.duration==subq), 
            Match.season_id==s_id).first()

        seasons = [e[0] for e in db.session.query(Season.number).all()]

        _args = dict(in_season_player_records=in_season_player_records, in_match_records=in_match_records,
            longest_match=longest_match, shortest_match=shortest_match, seasons=seasons, season_number=season_number)

    return render_template('season_records.html', **_args)


@seasons_bp.route('/current/heroes', methods=['GET'])
@seasons_bp.route('/<int:season_number>/heroes', methods=['GET'])
def heroes(season_number=-1):
    season_number, s_id = get_season_id(season_number)
    _sort = request.args.get('sort', 'played')
    if _sort not in ['hero', 'played', 'earned', 'winrate', 'kda']:
        _sort = 'played'
    order_by = _sort
    _desc = request.args.get('desc', 'yes')
    if _desc != 'no':
        _desc = 'yes'
        order_by = desc(order_by)
    hero_filter = request.args.get('hero', None)
    in_season_heroes = PlayerMatchStats.query.join(SeasonStats).filter(SeasonStats.season_id==s_id)\
            .with_entities(PlayerMatchStats.hero, func.count(PlayerMatchStats.id).label('played'), 
                (100 * func.sum(case([(PlayerMatchStats.pts_diff>0, 1)], else_=0))/func.count(PlayerMatchStats.id)).label('winrate'),
                func.sum(PlayerMatchStats.pts_diff).label('earned'),
                ((func.avg(PlayerMatchStats.kills) + func.avg(PlayerMatchStats.assists))/
                    func.avg(PlayerMatchStats.deaths+1)).label('kda'), 
            ).group_by(PlayerMatchStats.hero).order_by(order_by).all()

    seasons = [e[0] for e in db.session.query(Season.number).all()]

    return render_template('season_heroes.html', in_season_heroes=in_season_heroes, sort=_sort, _desc=desc, seasons=seasons, 
        season_number=season_number)
