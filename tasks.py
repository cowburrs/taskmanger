from datetime import datetime, timedelta
from enum import Enum

from api import api


class T(Enum):
    NAME = "name"
    CONDITIONS = "conditions"
    CARRYOVER = "carryover"
    START = "start"
    END = "end"
    TIMED = "hourly"


def isDayWeek(api: api, dayslist) -> bool:
    return any(api.dayofweek() == (x % 7) for x in dayslist)


tasks = [
    {
        T.NAME: (lambda api: f"{api.week()} Maths"),
        T.CONDITIONS: [(isDayWeek, (1, ))],
        T.CARRYOVER: timedelta(100),
        T.START: datetime(2026, 3, 2),
        T.END: datetime(2026, 4, 15),
        T.TIMED: timedelta(days=1),
    },
]
