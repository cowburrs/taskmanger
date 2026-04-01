import json
import os
from collections import Counter

from funcs import *
from model import Task, tasks

os.chdir(os.path.dirname(__file__))


def taskDictShorten(t, date):
    taskdict = {
        "name": t["name"],
        "due": ifhelper(
            (t["due"] != t["date"]),
            timedeltatostr(inttodate(t["due"]) - date),
            "No due date",
        ),
        "assigned": ifhelper(
            (t["date"] != datetoint(datetime(2000, 1, 1))),
            timedeltatostr(inttodate(t["date"]) - date),
            "N/A",
        ),
    }
    if t["desc"] != "":
        taskdict["desc"] = t["desc"]
    taskdict["date"] = t["date"]
    return taskdict


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
            "num": repeats,  # num repeats
        }
    )

    with open("tasks.json", "w") as f:
        json.dump(file, f, indent=2)


def deleteTasks():
    with open("tasks.json", "w") as f:
        json.dump([], f)

# TODO: i just had the best fucking idea ever, how about instead of parsing into done
# I make it create another json, donetasks.json, with donetasks but in proper format
# so i dont have to kill myself again and again
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
            todo.append(taskDictShorten(i, date))
    todo.append({"name": "End of Todo", "date": "0"})
    with open("todo.json", "w") as f:
        json.dump(todo, f, indent=2)


def getAllTodo(date: datetime):  # print all even not done
    try:
        with open("tasks.json") as f:
            tasks = json.load(f)
    except FileNotFoundError:
        tasks = []
    todo = []
    for i in tasks:
        if inttodate(i["date"]) <= date:
            todo.append(taskDictShorten(i, date))
    todo.append({"name": "End of AllTodo", "date": "0"})
    with open("jsons/alltodo.json", "w") as f:
        json.dump(todo, f, indent=2)


getAllTodo(datetime.now())


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
