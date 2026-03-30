from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Callable

from dayfuncs import *


def isDayWeek(dayslist) -> Callable[[datetime], bool]:
    return lambda date: any(dayofweek(date) == (x % 7) for x in dayslist)


def just(x):  # ITS A FUCKING POLYMORPHIC FUNCTION XDDDDDDDDDDDDDDDDDDDDDDD
    return lambda _: x


def justValue(x):
    return lambda: x


def checkEndDefault():
    return lambda x: x + timedelta(100 * 365)


def dueTimeDefault(delta: timedelta):
    return lambda x: x + delta


@dataclass
class Task:
    name: Callable
    conditions: list[Callable[[datetime], bool]]
    checkstart: Callable[[], datetime] = justValue(datetime(2000, 1, 1))
    checkend: Callable[[datetime], datetime] = checkEndDefault()
    checkdelta: Callable[[datetime], timedelta] = just(
        timedelta(0)
    )  # 0 means no checkdelta
    duetime: Callable[[datetime], datetime] = dueTimeDefault(
        timedelta(0)
    )  # 0 means never due
    checkstep: Callable[[datetime], timedelta] = just(
        timedelta(1)
    )  # time between each check, so like daily or hourly, minutely is possible. secondly not implementable though can be thought of as dt
    repeats: Callable[[datetime], int] = just(
        0
    )  # total number of repeats before it stop making 0 is inf
    importance: Callable[[datetime], int] = just(0)
    version: Callable[[datetime], int] = just(0)
    fudgeNumber: Callable[[datetime], int] = just(0)


tasks = [
    Task(
        name=lambda date: f"{week(date)} Maths",
        conditions=[isDayWeek([7, 7])],
        checkstart=justValue(datetime(2026, 3, 2)),
        checkend=just(datetime(2026, 4, 15)),
    )
]
