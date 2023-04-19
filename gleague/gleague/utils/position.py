import enum
from collections import OrderedDict
from collections import Counter
from typing import Optional, List

from sklearn.cluster import KMeans
import numpy as np


class Position(enum.Enum):
    top = "top"
    bottom = "bottom"
    middle = "middle"
    roam = "roam"
    safelane = "safelane"
    offlane = "offlane"


positions_radiant = OrderedDict(
    {
        (4500, 8000): Position.offlane,
        (7500, 5500): Position.safelane,
        (7200, 7200): Position.middle,
    }
)

positions_dire = OrderedDict(
    {
        (7000, 10000): Position.safelane,
        (10500, 8000): Position.offlane,
        (7200, 7200): Position.middle,
    }
)


def detect_position(points: List[dict], is_radiant: bool) -> Optional[Position]:
    if not points:
        return None
    positions = positions_radiant if is_radiant else positions_dire
    init = np.array(list(positions.keys()))
    kmeans = KMeans(n_clusters=3, init=init)
    result = kmeans.fit(points).labels_
    most_common, num_most_common = Counter(result).most_common(1)[0]
    if (len(points) / num_most_common) > 0.6:
        position = list(positions.items())[most_common][-1]
    else:
        position = Position.roam
    return position
