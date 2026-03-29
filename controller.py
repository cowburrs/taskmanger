import sqlite3
from datetime import datetime

from api import api
from tasks import T, tasks

conn = sqlite3.connect("tasks.db")
cursor = conn.cursor()

cursor.execute(
    """
    CREATE TABLE IF NOT EXISTS tasks (
        name TEXT,
        datetime INTEGER,
        carryover INTEGER DEFAULT 0,
        done INTEGER DEFAULT 0,
        id INTEGER PRIMARY KEY,
        UNIQUE(name, datetime)
    )
"""
)

cursor.execute(
    """
    CREATE TABLE IF NOT EXISTS completedTasks (
        name TEXT,
        datetime INTEGER,
        carryover INTEGER DEFAULT 0,
        done INTEGER DEFAULT 1,
        id INTEGER PRIMARY KEY,
        UNIQUE(name, datetime)
    )
"""
)
conn.commit()


def insertTask(name, datetime, carryover):
    cursor.execute(
        "INSERT OR IGNORE INTO tasks (name, datetime, carryover) VALUES (?, ?, ?)",
        (name, datetime, carryover),
    )
    conn.commit()


def markUndone(name, datetime):
    cursor.execute(
        "DELETE FROM completedTasks WHERE name = ? AND datetime = ?",
        (name, datetime),
    )
    conn.commit()


def markDone(name, datetime):
    cursor.execute(
        "INSERT OR IGNORE INTO completedTasks (name, datetime, carryover) SELECT name, datetime, carryover FROM tasks WHERE name = ? AND datetime = ?",
        (name, datetime),
    )
    cursor.execute(
        "UPDATE completedTasks SET done = 1 WHERE name = ? AND datetime = ?",
        (name, datetime),
    )
    conn.commit()


def markDoneOrUndone(name, datetime):
    result = cursor.execute(
        "SELECT done FROM completedTasks WHERE name = ? AND datetime = ?",
        (name, datetime),
    ).fetchone()

    if result and result[0] == 1:
        markUndone(name, datetime)
    else:
        markDone(name, datetime)


def getAllUndone():
    return cursor.execute(
        """
        SELECT t.name, t.datetime, t.carryover, t.id
        FROM tasks t
        LEFT JOIN completedTasks c ON t.name = c.name AND t.datetime = c.datetime AND t.carryover = c.carryover
        WHERE COALESCE(c.done, 0) = 0
    """
    ).fetchall()


def getPending(datetime):
    return cursor.execute(
        """
        SELECT t.name, t.datetime, t.carryover, t.id
        FROM tasks t
        LEFT JOIN completedTasks c ON t.name = c.name AND t.datetime = c.datetime AND t.carryover = c.carryover
        WHERE COALESCE(c.done, 0) = 0 AND t.datetime <= ? AND t.carryover >= ?
    """,
        (datetime, datetime),
    ).fetchall()


def getUpcoming(datetime):
    return cursor.execute(
        """
        SELECT t.name, t.datetime, t.carryover, t.id
        FROM tasks t
        LEFT JOIN completedTasks c ON t.name = c.name AND t.datetime = c.datetime AND t.carryover = c.carryover
        WHERE COALESCE(c.done, 0) = 0 AND t.datetime >= ?
    """,
        (datetime,),
    ).fetchall()


def getAll():
    return cursor.execute(
        """
        SELECT t.name, t.datetime, t.carryover, t.id
        FROM tasks t
    """
    ).fetchall()


def getAllDone():
    return cursor.execute(
        """
        SELECT c.name, c.datetime, c.carryover, c.id
        FROM completedTasks c
    """
    ).fetchall()


def buildTasks():
    cursor.execute("DELETE FROM tasks")
    conn.commit()
    for task in tasks:
        evaluate(task)


def evaluate(task):
    current = task[T.START]
    end = task[T.END]
    while end >= current:
        currentapi = api(current)
        if all(fn(currentapi, arg) for fn, arg in task[T.CONDITIONS]):
            insertTask(
                task[T.NAME](currentapi),
                currentapi.hash(),
                currentapi.hash(task[T.CARRYOVER]),
            )
        current += task[T.TIMED]
