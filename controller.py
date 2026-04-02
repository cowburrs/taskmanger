from funcs import *
from model import Task


def getDue(t, date):
    if t["due"] != t["date"]:
        return timedeltatostr(inttodate(t.get("due")) - date)
    else:
        return "N/A"


def getAssigned(t, date):
    if t["date"] != datetoint(datetime(2000, 1, 1)):
        return timedeltatostr(inttodate(t.get("date")) - date)
    else:
        return "N/A"


def sortByDue(tasks):
    return sorted(tasks, key=lambda i: i.get("due", float("inf")))


# TODO: I could also make it so that it takes an input, a list of time when i'm busy, or something
# And tell me how many hours i have left to work on something
# TODO: Add percentage, percentage time of due date done, so if half of due date has been exhausted then 50%
def taskDictShorten(t, date):
    taskdict = {
        "name": t["name"],
        "due": getDue(t, date),
        "assigned": getAssigned(t, date),
    }
    if t["desc"] != "":
        taskdict["desc"] = t["desc"]
    taskdict["date"] = t["date"]
    return taskdict


def createTask(task: Task, date: datetime, repeats):
    return {
        "name": task.name(date, repeats),
        "date": datetoint(date),
        "desc": task.description(date),
        "due": datetoint(task.duetime(date)),
        "prio": task.importance(date),
        "ver": task.version(date),
        "num": repeats,  # num repeats
    }


# TODO: i just had the best fucking idea ever, how about instead of parsing into done
# I make it create another json, donetasks.json, with donetasks but in proper format
# so i dont have to kill myself again and again
def getAllUndone():
    pass


# TODO: implement lookahead/foresight, and make things not disappear or whatever
def getToDo(date: datetime, tasks: list, done: list):
    todo = []
    donetasks = {(d["name"], d["date"]) for d in done}
    for i in tasks:
        if inttodate(i["date"]) <= date and ((i["name"], i["date"]) not in donetasks):
            todo.append(i)
    return todo


def getAllTodo(date: datetime):  # TODO: print all even not done
    pass


def getUpcoming(datetime):
    pass


def getAll():
    pass


def getAllDone():
    pass


def getAllDoneToday():  # could make this function be implemented in get all done
    pass


def getTasks(tasks):
    tasklist = list()
    for task in tasks:
        tasklist += evaluate(task)
    return tasklist


def evaluate(task: Task) -> list:
    taskdicts = list()
    check = task.checkstart()
    checkend = task.checkend(check)
    checkrepeats = task.checkrepeats(check, -1)
    repeats = 0
    if task.conditions == []:
        taskdicts.append(createTask(task, check, repeats))
        return taskdicts
    while checkend >= check and checkrepeats != 0:
        if all(fn(check) for fn in task.conditions):
            taskdicts.append(createTask(task, check, repeats))
            checkrepeats = task.checkrepeats(check, checkrepeats)
            repeats += 1
        check += task.checkstep(check)
    return taskdicts
