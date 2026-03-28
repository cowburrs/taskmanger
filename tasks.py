from datetime import datetime
from enum import Enum

from api import api


class T(Enum):
    NAME = "name"
    CONDITIONS = "conditions"
    CARRYOVER = "carryover"
    START = "start"
    END = "end"
    HOURLY = "hourly"


def isDayWeek(api: api, checkday) -> bool:
    return api.dayofweek() == (checkday % 7)


tasks = [
    {
        T.NAME: (lambda api: f"{api.week()} Maths"),
        T.CONDITIONS: [(isDayWeek, 1)],
        T.CARRYOVER: False,
        T.START: datetime(2026, 3, 1),
        T.END: datetime(2026, 3, 30),
        T.HOURLY: False,
    },
]
