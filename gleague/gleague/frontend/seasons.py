from flask import Blueprint
from flask import abort
from flask import current_app
from flask import render_template
from flask import request
from sqlalchemy import and_
from sqlalchemy import case
from sqlalchemy import desc
from sqlalchemy import func

from gleague.core import db
from gleague.models import Match
from gleague.models import PlayerMatchStats
from gleague.models import Season
from gleague.models import SeasonStats


seasons_bp = Blueprint('seasons', __name__)


def get_season_id(season_number):
    if season_number == -1:
        season = Season.current()
    else:
        season = Season.query.filter(Season.number == season_number).first()
        if not season:
            abort(404)
    return season.number, season.id


@seasons_bp.route('/current/players', methods=['GET'])
@seasons_bp.route('/<int:season_number>/players', methods=['GET'])
def players(season_number=-1):
    season_number, s_id = get_season_id(season_number)
    q = request.args.get('q')
    sort = request.args.get('sort', 'pts')
    page = int(request.args.get('page', 1))
    stats = SeasonStats.get_stats(season_number, q, sort)
    stats = stats.paginate(
        page, 15, True
    )
    seasons = [e[0] for e in db.session.query(Season.number).all()]
    return render_template(
        'redesign/season/players.html',
        stats=stats,
        sort=sort,
        seasons=seasons,
        season_number=season_number
    )


@seasons_bp.route('/current/records', methods=['GET'])
@seasons_bp.route('/<int:season_number>/records', methods=['GET'])
def records(season_number=-1):
    season_number, s_id = get_season_id(season_number)

    subq = (
        Match.query.join(Season)
        .filter(Season.id == s_id)
        .with_entities(func.max(Match.duration)).as_scalar()
    )
    longest_match = Match.query.filter(
        and_(Match.duration == subq, Match.season_id == s_id)
    ).first()
    seasons = [e[0] for e in db.session.query(Season.number).all()]
    template_context = {
        'longest_match': longest_match,
        'season_number': season_number,
        'seasons': seasons
    }
    if longest_match:
        subq = (
            SeasonStats.query
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(SeasonStats.longest_winstreak)).as_scalar()
        )
        win_streak_ss = db.session.query(SeasonStats).filter(
            and_(
                SeasonStats.season_id == s_id,
                SeasonStats.longest_winstreak == subq
            )
        ).first()

        subq = (
            SeasonStats.query
            .filter(SeasonStats.season_id == s_id)
            .with_entities(
                func.max(SeasonStats.longest_losestreak)
            ).as_scalar()
        )
        lose_streak_ss = db.session.query(SeasonStats).filter(
            and_(
                SeasonStats.season_id == s_id,
                SeasonStats.longest_losestreak == subq
            )
        ).first()

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(
                func.min(PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)
            )
            .as_scalar()
        )
        min_pts_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    (PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff) == subq
                )
            ).order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(
                func.max(PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff)
            )
            .as_scalar()
        )
        max_pts_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    (PlayerMatchStats.old_pts + PlayerMatchStats.pts_diff) == subq
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(
                func.max(
                    (PlayerMatchStats.kills + PlayerMatchStats.assists) /
                    (PlayerMatchStats.deaths + 1)
                )
            )
            .as_scalar()
        )
        max_kda_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    (
                        (PlayerMatchStats.kills + PlayerMatchStats.assists) /
                        (PlayerMatchStats.deaths + 1) == subq
                    )
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.kills)).as_scalar()
        )
        max_kills_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    PlayerMatchStats.kills == subq
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.deaths)).as_scalar()
        )
        max_deaths_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    PlayerMatchStats.deaths == subq
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.last_hits)).as_scalar()
        )
        most_lasthits_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    PlayerMatchStats.last_hits == subq
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.hero_damage)).as_scalar()
        )
        most_herodamage_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    PlayerMatchStats.hero_damage == subq
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.tower_damage)).as_scalar()
        )
        most_towerdamage_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    PlayerMatchStats.tower_damage == subq
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        subq = (
            PlayerMatchStats.query.join(SeasonStats)
            .filter(SeasonStats.season_id == s_id)
            .with_entities(func.max(PlayerMatchStats.damage_taken)).as_scalar()
        )
        most_damagetaken_pms = (
            db.session.query(PlayerMatchStats).join(SeasonStats)
            .filter(
                and_(
                    SeasonStats.season_id == s_id,
                    PlayerMatchStats.damage_taken == subq
                )
            )
            .order_by(PlayerMatchStats.id).first()
        )

        in_season_player_records = [
            (
                'Longest winstreak',
                win_streak_ss.player,
                win_streak_ss.longest_winstreak
            ),
            (
                'Longest losestreak',
                lose_streak_ss.player,
                lose_streak_ss.longest_losestreak
            ),
            (
                'Max pts ever',
                max_pts_pms.season_stats.player,
                max_pts_pms.old_pts + max_pts_pms.pts_diff
            ),
            (
                'Min pts ever',
                min_pts_pms.season_stats.player,
                min_pts_pms.old_pts + min_pts_pms.pts_diff
            )
        ]

        in_match_records = [
            (
                max_kda_pms.match_id,
                'Best KDA',
                max_kda_pms.season_stats.player,
                max_kda_pms.hero,
                (
                    (max_kda_pms.kills + max_kda_pms.assists) /
                    (max_kda_pms.deaths + 1)
                )
            ),
            (
                max_kills_pms.match_id,
                'Max kills',
                max_kills_pms.season_stats.player,
                max_kills_pms.hero,
                max_kills_pms.kills
            ),
            (
                max_deaths_pms.match_id,
                'Max deaths',
                max_deaths_pms.season_stats.player,
                max_deaths_pms.hero,
                max_deaths_pms.deaths
            ),
            (
                most_lasthits_pms.match_id,
                'Most last hits',
                most_lasthits_pms.season_stats.player,
                most_lasthits_pms.hero,
                most_lasthits_pms.last_hits
            )
        ]

        if most_herodamage_pms:
            in_match_records.append([
                most_herodamage_pms.match_id,
                'Most hero damage',
                most_herodamage_pms.season_stats.player,
                most_herodamage_pms.hero,
                most_herodamage_pms.hero_damage
            ])
        if most_towerdamage_pms:
            in_match_records.append([
                most_towerdamage_pms.match_id,
                'Most tower damage',
                most_towerdamage_pms.season_stats.player,
                most_towerdamage_pms.hero,
                most_towerdamage_pms.tower_damage
            ])
        if most_damagetaken_pms:
            in_match_records.append([
                most_damagetaken_pms.match_id,
                'Most damage taken',
                most_damagetaken_pms.season_stats.player,
                most_damagetaken_pms.hero,
                most_damagetaken_pms.damage_taken
            ])

        subq = (
            Match.query.join(Season)
            .filter(Season.id == s_id)
            .with_entities(func.min(Match.duration)).as_scalar()
        )
        shortest_match = Match.query.filter(
            Match.duration == subq, Match.season_id == s_id
        ).first()

        avg_match_duration = (
            Match.query.join(Season)
            .filter(Season.id == s_id)
            .with_entities(func.avg(Match.duration)).first()
        )
        avg_match_duration = (
            avg_match_duration[0] if avg_match_duration else None
        )

        radiant_winrate = (
            100 * func.sum(case([(Match.radiant_win == True, 1)], else_=0)) /
            func.count(Match.id)
        )
        dire_winrate = (
            100 * func.sum(case([(Match.radiant_win == False, 1)], else_=0)) /
            func.count(Match.id)
        )
        side_winrates = (
            Match.query.join(Season)
            .filter(Season.id == s_id)
            .with_entities(radiant_winrate, dire_winrate).first()
        )

        def get_duos(is_desc=True, limit=3):
            duos_result = db.session.execute(
                '''
                SELECT p1.nickname, p2.nickname, result.sum FROM (
                    SELECT ss1.steam_id as steam_id_1, ss2.steam_id as steam_id_2,
                    (
                        SELECT SUM(pms1.pts_diff)
                        FROM player_match_stats pms1
                        WHERE pms1.season_stats_id=ss1.id
                        AND EXISTS(
                            SELECT * FROM player_match_stats pms2
                            WHERE pms2.match_id=pms1.match_id AND pms2.pts_diff=pms1.pts_diff
                            AND pms2.season_stats_id=ss2.id
                        )
                    ) as sum
                    FROM season_stats ss1
                    JOIN season_stats ss2 ON ss1.steam_id < ss2.steam_id
                    AND ss1.season_id=ss2.season_id AND ss1.season_id=:season_id
                    ORDER BY sum {order_direction_desc}
                ) result
                JOIN player p1 ON p1.steam_id=result.steam_id_1
                JOIN player p2 ON p2.steam_id=result.steam_id_2
                WHERE result.sum is not NULL
                LIMIT :limit;
                '''.format(order_direction_desc=('DESC' if is_desc else 'ASC')),
                {
                    'season_id': s_id,
                    'limit': limit
                }
            )
            return duos_result.fetchall()

        template_context = {
            'in_season_player_records': in_season_player_records,
            'in_match_records': in_match_records,
            'longest_match': longest_match,
            'shortest_match': shortest_match,
            'seasons': seasons,
            'season_number': season_number,
            'avg_match_duration': avg_match_duration,
            'side_winrates': side_winrates,
            'powerful_duos': get_duos(),
            'powerless_duos': get_duos(False)
        }

    return render_template(
        'redesign/season/records.html',
        **template_context
    )


@seasons_bp.route('/current/heroes', methods=['GET'])
@seasons_bp.route('/<int:season_number>/heroes', methods=['GET'])
def heroes(season_number=-1):
    season_number, s_id = get_season_id(season_number)
    sort_arg = request.args.get('sort', 'played')
    if sort_arg not in ['hero', 'played', 'pts_diff', 'winrate', 'kda']:
        sort_arg = 'played'
    order_by = sort_arg
    is_desc = request.args.get('desc', 'yes')
    if is_desc != 'no':
        is_desc = 'yes'
        order_by = desc(order_by)
    hero_filter = request.args.get('hero', None)
    in_season_heroes = (
        PlayerMatchStats.query.join(SeasonStats)
        .filter(SeasonStats.season_id == s_id)
        .with_entities(
            PlayerMatchStats.hero,
            func.count(PlayerMatchStats.id).label('played'),
            (
                100 * func.sum(
                    case([(PlayerMatchStats.pts_diff > 0, 1)], else_=0)
                ) /
                func.count(PlayerMatchStats.id)
            ).label('winrate'),
            func.sum(PlayerMatchStats.pts_diff).label('pts_diff'),
            (
                (
                    func.avg(PlayerMatchStats.kills) +
                    func.avg(PlayerMatchStats.assists)
                ) / func.avg(PlayerMatchStats.deaths + 1)
            ).label('kda')
        )
        .group_by(PlayerMatchStats.hero).order_by(order_by).all()
    )

    seasons = [e[0] for e in db.session.query(Season.number).all()]

    return render_template(
        'redesign/season/heroes.html',
        in_season_heroes=in_season_heroes,
        sort=sort_arg,
        is_desc=desc,
        seasons=seasons,
        season_number=season_number
    )
