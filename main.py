import sqlite3
from datetime import datetime, timedelta
from typing import Callable

from api import api
from tasks import T, tasks


conn = sqlite3.connect("tasks.db")
cursor = conn.cursor()

cursor.execute(
    """
    CREATE TABLE IF NOT EXISTS tasks (
        name TEXT,
        day INTEGER,
        hour INTEGER,
        carryover INTEGER DEFAULT 0,
        done INTEGER DEFAULT 0,
        id INTEGER PRIMARY KEY,
        UNIQUE(name, day, hour)
    )
"""
)

cursor.execute(
    """
    CREATE TABLE IF NOT EXISTS completedTasks (
        name TEXT,
        day INTEGER,
        hour INTEGER,
        carryover INTEGER DEFAULT 0,
        done INTEGER DEFAULT 1,
        id INTEGER PRIMARY KEY,
        UNIQUE(name, day, hour)
    )
"""
)
conn.commit()


def insertTask(name, day, hour, carryover):
    cursor.execute(
        "INSERT OR IGNORE INTO tasks (name, day, hour, carryover) VALUES (?, ?, ?, ?)",
        (name, day, hour, carryover),
    )
    conn.commit()


def markDoneName(name, day, hour):
    cursor.execute(
        "INSERT OR IGNORE INTO completedTasks SELECT name, day, hour, 0 FROM tasks WHERE name = ? AND date = ? AND hour = ?",
        (name, day, hour),
    )
    cursor.execute(
        "UPDATE completedTasks SET done = 1 WHERE name = ? AND day = ? AND hour = ?",
        (name, day, hour),
    )
    conn.commit()


def markUndone(id):
    cursor.execute(
        "DELETE FROM completedTasks WHERE name = (SELECT name FROM tasks WHERE id = ?) AND day = (SELECT day FROM tasks WHERE id = ?) AND hour = (SELECT hour FROM tasks WHERE id = ?)",
        (id, id, id),
    )
    conn.commit()


def markDone(id):
    cursor.execute(
        "INSERT OR IGNORE INTO completedTasks (name, day, hour, carryover) SELECT name, day, hour, carryover FROM tasks WHERE id = ?",
        (id,),
    )
    cursor.execute(
        "UPDATE completedTasks SET done = 1 WHERE name = (SELECT name FROM tasks WHERE id = ?) AND day = (SELECT day FROM tasks WHERE id = ?) AND hour = (SELECT hour FROM tasks WHERE id = ?)",
        (id, id, id),
    )
    conn.commit()


def getPending():
    return cursor.execute(
        """
        SELECT t.*, COALESCE(c.done, 0) as done
        FROM tasks t
        LEFT JOIN completedTasks c ON t.name = c.name AND t.day = c.day AND t.hour = c.hour
        WHERE COALESCE(c.done, 0) = 0
    """
    ).fetchall()


def getAll():
    return cursor.execute("SELECT * FROM tasks").fetchall()


def cullTasks():
    cursor.execute("DELETE FROM tasks")
    conn.commit()
    for task in tasks:
        evaluateDays(task)




def evaluateDays(task):
    current = task[T.START]
    end = task[T.END]
    while end >= current:
        currentapi = api(current)
        if all(fn(currentapi, arg) for fn, arg in task[T.CONDITIONS]):
            insertTask(
                task[T.NAME](currentapi),
                currentapi.dayofyear(),
                currentapi.hour(),
                task[T.CARRYOVER],
            )
        current += timedelta(days=1)



evaluateDays(tasks[0])
testapi = api(datetime(2022, 6, 2, 21))
cullTasks()
markDone(2)
print(getPending())
print(getAll())
markUndone(2)
print(getPending())
print(getAll())
