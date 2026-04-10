local m = require("src.model")
local DAY = m.DAY
local HOUR = m.HOUR
local MIN = m.MIN
local timedelta = m.timedelta
local dt = m.dt
local isDateTime = m.isDateTime
local isHour = m.isHour
local isAbsWeek = m.isAbsWeek
local isNot = m.isNot
local isNotTeachingBreak = m.isNotTeachingBreak
local isDayWeek = m.isDayWeek
local isDayOfWeek = m.isDayOfWeek
local just = m.just
local checkEndDefault = m.checkEndDefault
local dueTimeDefault = m.dueTimeDefault
local dueTime = m.dueTime
local dueIn = m.dueIn
local dueOn = m.dueOn
local justRepeats = m.justRepeats
local listToTextbook = m.listToTextbook
local tasks = m.tasks
local Task = m.Task
local textBookTasks = m.textBookTasks
local oneTimeTask = m.oneTimeTask
local lectureTask = m.lectureTask
local lectureTasks = m.lectureTasks
local singleTasks = m.singleTasks
local spread = m.spread
local quizTask = m.quizTask
local worksheetTasks = m.worksheetTasks
local funcs = require("src.funcs")
local returntable = {
	oneTimeTask("Engn Team (TMC1)", dt(2026, 3, 30), dt(2026, 4, 19)),
	oneTimeTask("Engn Milestone 3", dt(2026, 3, 30), dt(2026, 4, 21)),
	oneTimeTask("Engn Self-Assessment Milestone 3", dt(2026, 4, 21), dt(2026, 4, 28)),
	oneTimeTask("Engn Milestone 4", dt(2026, 3, 30), dt(2026, 5, 12)),
	oneTimeTask("Engn Self-assessment Milestone 4", dt(2026, 5, 12), dt(2026, 5, 19)),
	oneTimeTask("Engn Reflection", dt(2026, 4, 20), dt(2026, 5, 29)),
	oneTimeTask("Engn Rover Design Report", dt(2026, 4, 20), dt(2026, 5, 29)),
	oneTimeTask("Engn Team (TMC2)", dt(2026, 5, 25), dt(2026, 6, 1)),
	{
		name = function(date, n)
			return "Math Week " .. (n + 6) .. " Assignment Q/Task"
		end,
		conditions = { isDayOfWeek(0), isNotTeachingBreak() },
		duetime = dueTime(timedelta(3)),
		checkstart = just(dt(2026, 3, 30)),
		checkrepeats = justRepeats(6),
	},
	{
		name = function(date, n)
			return "Comp Week " .. (n + 6) .. " Lab"
		end,
		conditions = { isDayWeek({ 4, 4 }), isNotTeachingBreak() },
		duetime = dueTime(timedelta(7)),
		checkstart = just(dt(2026, 3, 30, 13)),
		checkrepeats = justRepeats(6),
	},
	quizTask("Math", "MatLab", dt(2026, 3, 30), timedelta(3), 6, 6),
	quizTask("Phys", "Workshop Quiz", dt(2026, 3, 30), timedelta(24, 12), 6, 6),
	quizTask("Phys", "Pre-Reading Quiz", dt(2026, 3, 30), timedelta(24, 12), 6, 6),
	quizTask("Phys", "Lectures", dt(2026, 3, 30), timedelta(5), 6, 6),
	{
		name = function(date, n)
			return "Phys Week " .. (n + 6) .. " Lab Prep"
		end,
		conditions = { isDayWeek({ 0, 0 }), isNotTeachingBreak() },
		duetime = dueIn(2, 13),
		checkstart = just(dt(2026, 3, 30)),
		checkrepeats = justRepeats(6),
	},
	{
		name = function(date, n)
			return "Phys Week " .. (n + 6) .. " Lab Submission"
		end,
		conditions = { isDayWeek({ 2, 2 }), isHour(13), isNotTeachingBreak() },
		duetime = dueIn(1, 4),
		checkstart = just(dt(2026, 3, 30)),
		checkrepeats = justRepeats(6),
		checkstep = just(HOUR),
	},
	lectureTasks("math", 6, {
		{ 1, dt(2026, 3, 30, 9) },
		{ 2, dt(2026, 3, 30, 9) },
	}, 6),
	lectureTasks("comp", 6, {
		{ 0, dt(2026, 3, 30, 14) },
		{ 1, dt(2026, 3, 30, 15) },
		{ 2, dt(2026, 3, 30, 12) },
		{ 3, dt(2026, 3, 30, 8) },
	}, 6),
	lectureTasks("engn", 6, {
		{ 0, dt(2026, 3, 30, 14) },
		{ 1, dt(2026, 3, 30, 16) },
	}, 6),
	singleTasks({
		"Understand Nullspaces",
		"vpython",
		"Comp lab 6 folds",
		"comp 5 final q",
		"gitignore vesktop and fonts",
		"make clear tabs task weekly",
		"debloat computer",
		"shellnix/devenvs",
	}),
	worksheetTasks("Lambda Calculus", dt(2025, 4, 4), timedelta(1), 8, {4, 6, 10})
	-- textBookTasks("Jstweart", dt(2026, 4, 4), dt(2026, 5, 4), { 6, 8, 7, 5, 8, 6, 7, 8, 5, 9, 8, 8, 9 }),
}

return returntable
