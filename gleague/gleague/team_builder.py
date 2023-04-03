import random
import uuid
from typing import List, Tuple, Union, Optional

import dataclasses as dc

from gleague.core import db
from gleague.models import Season
from gleague.models import SeasonStats
from gleague.models import Player
from gleague.models import TeamSeed
from gleague.models import TeamSeedPlayer


@dc.dataclass
class PlayerTuple:
    pts: int
    player: Optional[Player] = None


@dc.dataclass
class TeamBuilderService:
    season: Season

    def get_players(self) -> List[Player]:
        return Player.query.all()

    def get_teams_from_seed(
        self, seed: TeamSeed
    ) -> Tuple[List[PlayerTuple], List[PlayerTuple]]:
        team1 = []
        team2 = []
        for tsp in seed.team_seed_players:
            if tsp.player and tsp.player.season_stats[0].season_id == self.season.id:
                pts = tsp.player.season_stats[0].pts
            else:
                pts = SeasonStats.pts.default.arg
            player_tuple = PlayerTuple(
                pts=pts,
                player=tsp.player,
            )
            if tsp.is_radiant:
                team1.append(player_tuple)
            else:
                team2.append(player_tuple)
        return (team1, team2)

    def shuffle_teams(
        self, player_ids: List[Union[str, None]]
    ) -> Tuple[List[PlayerTuple], List[PlayerTuple]]:
        players = Player.query.filter(
            Player.steam_id.in_(filter(bool, player_ids))
        ).all()
        tuples = [
            PlayerTuple(
                pts=(
                    player.season_stats[0].pts
                    if player.season_stats[0].season_id == self.season.id
                    else SeasonStats.pts.default.arg
                ),
                player=player,
            )
            for player in players
        ]
        if len(tuples) < 10:
            tuples += [PlayerTuple(pts=SeasonStats.pts.default.arg)] * (
                10 - len(tuples)
            )

        teams = sort_by_pts(tuples)
        return teams

    def save_seed(
        self, teams: Tuple[List[PlayerTuple], List[PlayerTuple]]
    ) -> TeamSeed:
        seed = TeamSeed(id=str(uuid.uuid4()), season=self.season)
        db.session.add(seed)
        for is_dire, team in enumerate(teams):
            for team_player in team:
                is_radiant = bool(is_dire) is False
                seed_player = TeamSeedPlayer(
                    seed=seed,
                    player=team_player.player,
                    is_radiant=is_radiant,
                )
                db.session.add(seed_player)
        db.session.commit()
        return seed


def sort_by_pts(players: List[PlayerTuple], t=50):
    def total_pts(players: List[PlayerTuple]) -> int:
        return sum((players[i].pts for i in range(len(players))))

    def pts_diff(radiant: List[PlayerTuple], dire: List[PlayerTuple]) -> int:
        return abs(total_pts(radiant) - total_pts(dire))

    def shuffle(
        players: List[PlayerTuple],
    ) -> Tuple[List[PlayerTuple], List[PlayerTuple]]:
        teams = ([], [])
        radiant = teams[0]
        dire = teams[1]
        for i in range(0, len(players), 2):
            if random.randrange(0, 2):
                radiant.append(players[i])
                dire.append(players[i + 1])
            else:
                radiant.append(players[i + 1])
                dire.append(players[i])
        return teams

    sorted_players = sorted(players, key=lambda p: p.pts)
    best_attempt = shuffle(sorted_players)
    best_diff = pts_diff(*best_attempt)

    for __ in range(t):
        attempt = shuffle(sorted_players)
        diff = pts_diff(*attempt)
        if diff < best_diff:
            best_diff = diff
            best_attempt = attempt

    return best_attempt
