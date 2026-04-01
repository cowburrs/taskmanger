from dataclasses import dataclass, field
from datetime import datetime, timedelta
from typing import Callable

from funcs import *


def isDateTime(day: datetime) -> Callable[[datetime], bool]:
    return lambda date: day == date


def isHour(hour: int) -> Callable[[datetime], bool]:
    return lambda date: hour == date.hour


def isAbsWeek(week: int) -> Callable[[datetime], bool]:
    return lambda date: week == absweek(date)


def isNotAbsWeek(week: int) -> Callable[[datetime], bool]:
    return lambda date: week != absweek(date)


def isNotTeachingBreak() -> Callable[[datetime], bool]:
    return lambda date: absweek(date) not in [2936, 2937]


def isDayWeek(dayslist: list[int]) -> Callable[[datetime], bool]:
    return lambda date: any(dayofweek(date) == (x % 7) for x in dayslist)


def isDayOfWeek(day: int) -> Callable[[datetime], bool]:
    return lambda date: (dayofweek(date) == (day % 7))


def just(x):  # ITS A FUCKING POLYMORPHIC FUNCTION XDDDDDDDDDDDDDDDDDDDDDDD
    return lambda _: x


def justValue(x):
    return lambda: x


def checkEndDefault():
    return lambda x: x + timedelta(100 * 365)


def dueTimeDefault():
    return lambda x: x


def dueTime(delta: timedelta):
    return lambda x: x + delta


def dueIn(days=0, hours=0, minutes=0, weeks=0, seconds=0):
    delta = timedelta(
        days=days, hours=hours, minutes=minutes, weeks=weeks, seconds=seconds
    )
    return lambda x: x + delta


def dueOn(date: datetime):
    return lambda _: date


def infiniteRepeats():
    return lambda _, __: -1


def justName(s: str):
    return lambda _, __: s


def justRepeats(x: int):
    def repeatsN(_, n):
        if n == -1:
            return x
        else:
            return n - 1

    return repeatsN


def oneTimeTask(Name: str, Start: datetime, Due: datetime):
    return Task(
        name=justName(Name),
        conditions=[isDateTime(Start)],
        duetime=dueOn(Due),
        checkstart=justValue(Start),
    )


def lectureTask(
    Subject: str, Letter: str, Week, WeekDay: int, Start: datetime, Repeats: int
):
    return Task(
        name=lambda date, n: f"{Subject.capitalize()} Week {n + Week} Lec{Letter.upper()}",
        conditions=[isDayOfWeek(WeekDay), isNotTeachingBreak()],
        duetime=dueTime(timedelta(5)),
        checkstart=justValue(Start),
        checkrepeats=justRepeats(Repeats),
    )


def lectureTasks(Subject: str, Week, Repeats: int, Sessions: list[list]):
    return tuple(
        lectureTask(Subject, letter, Week, WeekDay, Start, Repeats)
        for letter, (WeekDay, Start) in zip("ABCDEFG", Sessions)
    )


def singleTasks(str: list[str]):
    return tuple(justName(s) for s in str)


# TODO: I reckon i'd want something like a 'instant delete' check, or like a checkdisappear
# so that if it passes this timedelta, it wont show up as a task anymore
@dataclass
class Task:
    name: Callable[[datetime, int], str]
    conditions: list[Callable[[datetime], bool]] = field(default_factory=list)
    description: Callable[[datetime], str] = just("")
    duetime: Callable[[datetime], datetime] = dueTimeDefault()  # 0 means never due
    importance: Callable[[datetime], int] = just(0)
    version: Callable[[datetime], float] = just(0)
    checkstart: Callable[[], datetime] = justValue(datetime(2026, 2, 1))
    checkend: Callable[[datetime], datetime] = checkEndDefault()
    checkdelta: Callable[[datetime], timedelta] = just(
        timedelta(0)
    )  # 0 means no checkdelta
    checktime: datetime | None = None
    checkstep: Callable[[datetime], timedelta] = just(
        timedelta(1)
    )  # time between each check, so like daily or hourly, minutely is possible. secondly not implementable though can be thought of as dt
    checkrepeats: Callable[[datetime, int], int] = justRepeats(
        1
    )  # total number of repeats before it stop making -1 is inf (or any negative number, it stops at 0)


# TODO: Make this final bit modular and i havbe a working prototype
# TODO: I think checkstep could be what i use
# TODO: Textbook Chaptersssssssss, and lambda calculus things too
# how do i even do textbook chapters? when they're diffrent like 7.1-7.5 vs 4.1-4.13, i have an idea, a list of ints, each for the size of each chapter, and yeah yeah yeah i got it
# I could just make a list of chapte rlengths[1, 3, 5], andit will expand it to a total list
# like 1.1, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.4, 3.5
# and just index into it based on how many times repeated, like []
# TODO: I should make constructors for tasks, like curyring so that i dont have to specify everytghin, for example lecture tasks are like 3 days due date and stuff(or no due date if i decide to change in the future)
# TODO: I could incorporate gum cli prettier tool to ask like yes no do i want to gitshit and yes no do i want to go back and change/add more things
# Or i could make it that when you do exit, it checks if done has been changed, and auto git add commits that. that sounds smart
tasks = [
    # TODO: i should make a function, which takes a list of strings, and creates a bunch of tasks with just a name justtname ykwim
    Task(
        name=justName("Understand Nullspaces"),
    ),
    # *singleTasks(["Understand Nullspaces", "Kill myself", "Just kidding"]), # TODO: MAKE THIS SHIT WORK
    Task(
        name=lambda date, n: f"Phys Week {n + 6} Lectures",
        conditions=[isDayWeek([0, 0]), isNotTeachingBreak()],
        duetime=dueTime(timedelta(5)),
        checkstart=justValue(datetime(2026, 3, 30)),
        checkrepeats=justRepeats(6),
    ),
    Task(
        name=lambda date, n: f"Phys Week {n+6} Lab Prep",
        conditions=[isDayWeek([0, 0]), isNotTeachingBreak()],
        duetime=dueIn(days=2, hours=13),
        checkstart=justValue(datetime(2026, 3, 30)),
        checkrepeats=justRepeats(6),
    ),
    Task(
        name=lambda date, n: f"Phys Week {n+6} Lab Submission",
        conditions=[isDayWeek([2, 2]), isHour(13), isNotTeachingBreak()],
        duetime=dueIn(days=1, hours=4),
        checkstart=justValue(datetime(2026, 3, 30)),
        checkrepeats=justRepeats(6),
        checkstep=just(timedelta(hours=1)),
    ),
    # TODO: quizTask could exist methinks
    Task(
        name=lambda date, n: f"Phys Week {week(date) - 8} Pre-Reading Quiz",
        conditions=[isDayWeek([0, 0])],
        duetime=dueTime(timedelta(24, hours=12)),
        checkstart=justValue(datetime(2026, 3, 30)),
        checkrepeats=justRepeats(6),
    ),
    Task(
        name=lambda date, n: f"Phys Week {week(date) - 8} Workshop Quiz",
        conditions=[isDayWeek([0, 0])],
        duetime=dueTime(timedelta(24, hours=12)),
        checkstart=justValue(datetime(2026, 3, 30)),
        checkrepeats=justRepeats(6),
    ),
    # TODO: I could make a schoolweek function, so that the names can be done better, an n function curry is what i mean to remove the date cause its bloat at the end of the day
    # TODO: wait i just remember what i was thinking, like schoolweek function for the name, like week - number of schoolweeks had, not currying
    Task(
        name=lambda date, n: f"Comp Week {n + 6} Lab",
        conditions=[isDayWeek([4, 4]), isNotTeachingBreak()],
        duetime=dueTime(timedelta(7)),
        checkstart=justValue(datetime(2026, 3, 30, 13)),
        checkrepeats=justRepeats(6),
    ),
    Task(
        name=lambda date, n: f"Math Week {n + 6} MatLab",
        conditions=[isDayOfWeek(0), isNotTeachingBreak()],
        duetime=dueTime(timedelta(3)),
        checkstart=justValue(datetime(2026, 3, 30)),
        checkrepeats=justRepeats(6),
    ),
    # TODO: Names need to be done better just straight up
    Task(
        name=lambda date, n: f"Math Week {n + 6} Assignment Q/Task",
        conditions=[isDayOfWeek(0), isNotTeachingBreak()],
        duetime=dueTime(timedelta(3)),
        checkstart=justValue(datetime(2026, 3, 30)),
        checkrepeats=justRepeats(6),
    ),
    oneTimeTask(
        "Engn Team (TMC1)",
        datetime(2026, 3, 30),
        datetime(2026, 4, 19),
    ),
    oneTimeTask(
        "Engn Milestone 3",
        datetime(2026, 3, 30),
        datetime(2026, 4, 21),
    ),
    oneTimeTask(
        "Engn Self-Assessment Milestone 3",
        datetime(2026, 4, 21),
        datetime(2026, 4, 28),
    ),
    oneTimeTask(
        "Engn Milestone 4",
        datetime(2026, 3, 30),
        datetime(2026, 5, 12),
    ),
    oneTimeTask(
        "Engn Self-assessment Milestone 4",
        datetime(2026, 5, 12),
        datetime(2026, 5, 19),
    ),
    oneTimeTask(
        "Engn Reflection",
        datetime(2026, 4, 20),
        datetime(2026, 5, 29),
    ),
    oneTimeTask(
        "Engn Rover Design Report",
        datetime(2026, 4, 20),
        datetime(2026, 5, 29),
    ),
    oneTimeTask(
        "Engn Team (TMC2)",
        datetime(2026, 5, 25),
        datetime(2026, 6, 1),
    ),
    *lectureTasks(
        "math",
        6,
        6,
        [
            [1, datetime(2026, 3, 30, 9)],
            [2, datetime(2026, 3, 30, 9)],
        ],
    ),
    *lectureTasks(
        "comp",
        6,
        6,
        [
            [0, datetime(2026, 3, 30, 14)],
            [1, datetime(2026, 3, 30, 15)],
            [2, datetime(2026, 3, 30, 12)],
            [3, datetime(2026, 3, 30, 8)],
        ],
    ),
    *lectureTasks(
        "engn",
        6,
        6,
        [
            [0, datetime(2026, 3, 30, 14)],
            [1, datetime(2026, 3, 30, 16)],
        ],
    ),
]
