import enum
from collections import OrderedDict
from collections import Counter

from sklearn.cluster import KMeans
import numpy as np


class Position(enum.Enum):
    top = "top"
    bottom = "bottom"
    middle = "middle"
    roam = "roam"


positions = OrderedDict(
    {
        (3500, 11000): Position.top,
        (11500, 4000): Position.bottom,
        (7200, 7200): Position.middle,
    }
)


def detect_position(points):
    init = np.array(list(positions.keys()))
    kmeans = KMeans(n_clusters=3, init=init)
    result = kmeans.fit(points).labels_
    most_common, num_most_common = Counter(result).most_common(1)[0]
    if (len(points) / num_most_common) > 0.6:
        position = list(positions.items())[most_common][-1]
    else:
        position = Position.roam
    return position
