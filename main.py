import json
import os
# TODO: its in json file format, i could theoretically at least format the strings
# or even make a gui for it

os.chdir(os.path.dirname(__file__))
from controller import *
from model import listToTextbook, tasks, name

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
print("What?")
print("{n}".format(n=2))
print("nvm")

with open("todo.json", "w") as f:
    json.dump(todo, f)
