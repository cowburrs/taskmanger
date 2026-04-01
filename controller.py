import json
import os
import sqlite3
import subprocess

from funcs import *
from model import Task, tasks

os.chdir(os.path.dirname(__file__))


def insertTask(task: Task, date: datetime, repeats):
    try:
        with open("tasks.json") as f:
            file = json.load(f)
    except FileNotFoundError:
        file = []

    file.append(
        {
            "name": task.name(date, repeats),
            "date": datetoint(date),
            "desc": task.description(date),
            "due": datetoint(task.duetime(date)),
            "prio": task.importance(date),
            "ver": task.version(date),
            # "nth time" TODO: record how many times its been seen before
        }
    )
    # print(
    #     {
    #         "name": task.name(date, repeats),
    #         # "due": timedeltatostr(task.duetime(date) - datetime.now()),
    #         # "duedate": task.duetime(date).strftime("%B %d, %Y %H:%M:%S"),
    #         "date": str(date)
    #     }
    # )

    with open("tasks.json", "w") as f:
        json.dump(file, f, indent=2)


def deleteTasks():
    with open("tasks.json", "w") as f:
        json.dump([], f)
    with open("todo.json", "w") as f:
        json.dump([], f)


def getAllUndone():
    pass


# TODO: Expand this so that i can insert it into a different file, this doesnt need ot be just todo, cause its any date time, maybe str and another datetime, one to check at this time, another for the curren ttime, and string for the filename
# TODO: I could also make it so that it takes an input, a list of time when i'm busy, or something
# TODO: And tell me how many hours i have left to work on something
def getToDo(date: datetime):
    try:
        with open("tasks.json") as f:
            tasks = json.load(f)
    except FileNotFoundError:
        tasks = []
    try:
        with open("todo.json") as f:
            todo = json.load(f)
    except FileNotFoundError:
        todo = []
    try:
        with open("done.json") as f:
            done = json.load(f)
            # done.remove()
    except FileNotFoundError:
        done = []
        # TODO: i maybe want to change d[] to d.get[] for like safety, but too lazy
    donetasks = {(d["name"], d["date"]) for d in done}
    for i in tasks:
        if inttodate(i["date"]) <= date and ((i["name"], i["date"]) not in donetasks):
            taskdict = {
                "name": i["name"],
                "due": ifhelper(
                    (i["due"] != i["date"]),
                    timedeltatostr(inttodate(i["due"]) - date),
                    "No due date",
                ),
            }
            if i["desc"] != "":
                taskdict["desc"] = i["desc"]
            taskdict["date"] = i["date"]
            todo.append(taskdict)
            # TODO: Add when it was assigned, like how long ago it was., like for example a comp thing assigned 1 minute ago would be -1 minute some seconds
    todo.append({"name": "End of Todo", "date": "0"})
    with open("todo.json", "w") as f:
        json.dump(todo, f, indent=2)


def getUpcoming(datetime):
    pass


def getAll():
    pass


def getAllDone():
    pass


def buildTasks():
    deleteTasks()
    for task in tasks:
        evaluate(task)
    getToDo(datetime.now())
    # TODO: Just add this pretier to the todo function in bash
    subprocess.run(["bash", "-c", "prettier --write *.json >/dev/null"])


def evaluate(task: Task):
    check = task.checkstart()
    checkend = task.checkend(check)
    checkrepeats = task.checkrepeats(check, -1)
    repeats = 0
    if task.conditions == []:
        insertTask(task, check, repeats)
        return
    while checkend >= check and checkrepeats != 0:
        if all(fn(check) for fn in task.conditions):
            insertTask(task, check, repeats)
            checkrepeats = task.checkrepeats(check, checkrepeats)
            repeats += 1
        check += task.checkstep(check)


buildTasks()
