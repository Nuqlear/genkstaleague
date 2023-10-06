import dataclasses as dc
from typing import Optional, List, Tuple, Dict, Any

from gleague.models import Match, PlayerMatchStats


@dc.dataclass
class TeamStatsHistory:
    time: List[int] = dc.field(default_factory=list)
    radiant_advantage_networth: List[int] = dc.field(default_factory=list)
    radiant_advantage_xp: List[int] = dc.field(default_factory=list)

    def to_dict(self) -> Dict[str, List[int]]:
        return dc.asdict(self)


def get_teams_stats_history(match: Match) -> Optional[TeamStatsHistory]:
    if not (match.players_stats[0].networth and match.players_stats[0].xp):
        return None
    stats_history = TeamStatsHistory()
    iterator = TeamStatsHistoryIterator(match.players_stats)

    sec_to_nano_seconds = 1000000000

    for radiant, dire in iterator:
        time1 = time2 = None
        radiant_networth = radiant_xp = 0
        dire_networth = dire_xp = 0
        for player in radiant:
            time1 = player["networth"]["time"]
            radiant_networth += player["networth"]["value"]
            radiant_xp += player["xp"]["value"]
        for player in dire:
            time2 = player["networth"]["time"]
            dire_networth += player["networth"]["value"]
            dire_xp += player["xp"]["value"]

        if time1 != time2 or time1 is None:
            continue

        radiant_advantage_networth = radiant_networth - dire_networth
        radiant_advantage_xp = radiant_xp - dire_xp

        stats_history.time.append(time1 / sec_to_nano_seconds)
        stats_history.radiant_advantage_networth.append(radiant_advantage_networth)
        stats_history.radiant_advantage_xp.append(radiant_advantage_xp)

    return stats_history


class TeamStatsHistoryIterator:
    def __init__(self, player_stats: List[PlayerMatchStats]):
        self.radiant_iter = [
            {
                "networth": iter(stats.networth),
                "xp": iter(stats.xp),
            }
            for stats in player_stats[:5]
        ]
        self.dire_iter = [
            {
                "networth": iter(stats.networth),
                "xp": iter(stats.xp),
            }
            for stats in player_stats[5:]
        ]

    def __iter__(self):
        return self

    def __next__(self) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
        return (
            [
                {
                    "networth": next(stats["networth"]),
                    "xp": next(stats["xp"]),
                }
                for stats in self.radiant_iter
            ],
            [
                {
                    "networth": next(stats["networth"]),
                    "xp": next(stats["xp"]),
                }
                for stats in self.dire_iter
            ],
        )
