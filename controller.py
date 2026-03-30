import sqlite3
from datetime import datetime

from dayfuncs import *
from tasks import Task, tasks

conn = sqlite3.connect("tasks.db")
cursor = conn.cursor()

# TODO: make table bigger and stuff. todo later. like add stuff like fudgefactor and priority whatveer
cursor.execute(
    """
    CREATE TABLE IF NOT EXISTS tasks (
        name TEXT,
        datetime INTEGER,
        duedate INTEGER DEFAULT 0,
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
        duedate INTEGER DEFAULT 0,
        done INTEGER DEFAULT 1,
        id INTEGER PRIMARY KEY,
        UNIQUE(name, datetime)
    )
"""
)
conn.commit()


def insertTask(name, datetime, duedate):
    cursor.execute(
        "INSERT OR IGNORE INTO tasks (name, datetime, duedate) VALUES (?, ?, ?)",
        (name, datetime, duedate),
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
        "INSERT OR IGNORE INTO completedTasks (name, datetime, duedate) SELECT name, datetime, duedate FROM tasks WHERE name = ? AND datetime = ?",
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
        SELECT t.name, t.datetime, t.duedate, t.id
        FROM tasks t
        LEFT JOIN completedTasks c ON t.name = c.name AND t.datetime = c.datetime AND t.duedate = c.duedate
        WHERE COALESCE(c.done, 0) = 0
    """
    ).fetchall()


def getPending(datetime):
    return cursor.execute(
        """
        SELECT t.name, t.datetime, t.duedate, t.id
        FROM tasks t
        LEFT JOIN completedTasks c ON t.name = c.name AND t.datetime = c.datetime
        WHERE COALESCE(c.done, 0) = 0 AND t.datetime <= ? AND (t.duedate >= ? OR t.duedate <= t.datetime)
    """,
        (datetime, datetime),
    ).fetchall()


def getUpcoming(datetime):
    return cursor.execute(
        """
        SELECT t.name, t.datetime, t.duedate, t.id
        FROM tasks t
        LEFT JOIN completedTasks c ON t.name = c.name AND t.datetime = c.datetime
        WHERE COALESCE(c.done, 0) = 0 AND t.datetime >= ?
    """,
        (datetime,),
    ).fetchall()


def getAll():
    return cursor.execute(
        """
        SELECT t.name, t.datetime, t.duedate, t.id
        FROM tasks t
    """
    ).fetchall()


def getAllDone():
    return cursor.execute(
        """
        SELECT c.name, c.datetime, c.duedate, c.id
        FROM completedTasks c
    """
    ).fetchall()


def buildTasks():
    cursor.execute("DELETE FROM tasks")
    conn.commit()
    for task in tasks:
        evaluate(task)


def evaluate(task: Task):
    check = task.checkstart()
    checkend = task.checkend(check)
    while checkend >= check:
        if all(fn(check) for fn in task.conditions):
            insertTask(
                task.name(check),
                datetoint(check),
                datetoint(task.duetime(check)),
            )
        check += task.checkstep(check)

