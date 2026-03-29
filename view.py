import sys

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont, QPalette
from PyQt6.QtWidgets import (
    QApplication,
    QFrame,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QScrollArea,
    QVBoxLayout,
    QWidget,
)

from controller import *

buildTasks()
todo, finished, upcoming = [], [], []
todo = list()
for i in getPending(api(datetime.now()).hash()):
    todo.append((i[0], i[1]))
print(todo)
for i in getAllDone():
    finished.append((i[0], i[1]))
for i in getUpcoming(api(datetime.now()).hash()):
    upcoming.append((i[0], i[1]))

COLUMNS = [
    {"title": "To Do", "tasks": todo},
    {"title": "Finished", "tasks": finished},
    {"title": "Upcoming", "tasks": upcoming},
]


class TaskCard(QFrame):
    def __init__(self, task):
        super().__init__()
        self.title = task
        self.setFrameShape(QFrame.Shape.Box)

        self.setAutoFillBackground(True)
        p = self.palette()
        p.setColor(
            QPalette.ColorRole.Window,
            QApplication.palette().color(QPalette.ColorRole.Button),
        )
        self.setPalette(p)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 8, 10, 8)
        label = QLabel(task[0] + "\n" + str(datetime.strptime(str(task[1]), "%Y%m%d%H%M")))
        layout.addWidget(label)

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            print(f"clicked!{self.title}")


class KanbanColumn(QWidget):
    def __init__(self, data):
        super().__init__()
        self.setFixedWidth(220)
        layout = QVBoxLayout(self)
        layout.setSpacing(8)

        header = QLabel(data["title"])
        header.setFont(QFont("sans-serif", 11, QFont.Weight.Bold))
        header.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(header)

        for task in data["tasks"]:
            layout.addWidget(TaskCard(task))

        layout.addStretch()


class KanbanBoard(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Kanban")
        self.setMinimumSize(800, 500)

        central = QWidget()
        self.setCentralWidget(central)
        layout = QHBoxLayout(central)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(16)

        for col in COLUMNS:
            layout.addWidget(KanbanColumn(col))

        layout.addStretch()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = KanbanBoard()
    window.show()
    sys.exit(app.exec())
