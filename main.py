import json
import os

os.chdir(os.path.dirname(__file__))
from controller import *
from model import tasks

date = datetime.now()

with open("tasks.json", "w") as f:
    json.dump([], f)

try:
    with open("done.json") as f:
        done = json.load(f)
except FileNotFoundError:
    done = []
tasks = getTasks(tasks)
todo = getToDo(datetime.now(), tasks, done)


todo = sortByDue(todo)

todo = list(map((lambda t: taskDictShorten(t, date)), todo))
for i in todo:
    print(i)
    pass
todo.append({"name": "End of Todo", "date": 0})

with open("todo.json", "w") as f:
    json.dump(todo, f)
