import json

from controller import buildTasks

buildTasks()

try:
    with open("todo.json") as f:
        todo = json.load(f)
except FileNotFoundError:
    todo = []
try:
    with open("tasks.json") as f:
        tasks = json.load(f)
except FileNotFoundError:
    tasks = []
    # print(i)
lookup = {(t["name"], t["date"]): t["due"] for t in tasks}
todo.sort(key=lambda i: lookup.get((i["name"], i["date"]), float("inf"))) # i'm too fried for this shit bruh

for i in todo:
    print(i)
    pass
