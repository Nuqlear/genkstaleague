import enum
from collections import OrderedDict
from collections import Counter
from typing import Optional, List


MID_THRESHOLD = 2000


class Position(enum.Enum):
    top = "top"
    bottom = "bottom"
    middle = "middle"
    roam = "roam"


def point_position(point: List[int]):
    if abs(pair[0] - pair[1]) < MID_THRESHOLD:
        return Position.middle
    if pair[0] - pair[1] < 0:
        return Position.top
    return Position.bottom


def detect_position(points: List[List[int]]) -> Optional[Position]:
    if not points:
        return None
    result = [point_position(point) for point in points]
    most_common, num_most_common = Counter(result).most_common(1)[0]
    if (len(points) / num_most_common) > 0.6:
        position = most_common
    else:
        position = Position.roam
    return position
