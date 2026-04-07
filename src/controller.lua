local funcs = require("src/funcs")

local inttodate = funcs.inttodate
local datetoint = funcs.datetoint
local timedeltatostr = funcs.timedeltatostr

-- ─── Display helpers ──────────────────────────────────────────────────────────

local function getDue(t, date)
	if t.due ~= t.date then
		return timedeltatostr(inttodate(t.due) - date)
	else
		return "N/A"
	end
end

local function getAssigned(t, date)
	local epoch2000 = os.time({ year = 2000, month = 1, day = 1, hour = 0, min = 0, sec = 0 })
	if inttodate(t.date) ~= epoch2000 then
		return timedeltatostr(inttodate(t.date) - date)
	else
		return "N/A"
	end
end

local function getPercentageDone(t, date)
	if t.date ~= t.due then
		return (date - inttodate(t.date)) / (inttodate(t.due) - inttodate(t.date))
	else
		return 0
	end
end

local function sortByDue(tasks)
	local sorted = {}
	for _, v in ipairs(tasks) do
		table.insert(sorted, v)
	end
	table.sort(sorted, function(a, b)
		local ad = a.due or math.huge
		local bd = b.due or math.huge
		return ad < bd
	end)
	return sorted
end

-- TODO: I could also make it so that it takes an input, a list of time when i'm busy, or something
-- And tell me how many hours i have left to work on something
local function taskDictShorten(t, date)
	local taskdict = {
		name = t.name,
		due = getDue(t, date),
		assigned = getAssigned(t, date),
	}
	if t.desc ~= "" then
		taskdict.desc = t.desc
	end
	taskdict["%"] = math.floor(getPercentageDone(t, date) * 100)
	taskdict.date = t.date
	return taskdict
end

local function shortDictPrint(dict)
	for _, t in ipairs(dict) do
		print(string.format("[%3d%%] %-30s assigned: %-20s due: %s", t["%"], t.name, t.assigned, t.due or "N/A"))
	end
end

local function doneTaskPrint(dict, date)
	for _, t in ipairs(dict) do
		print(string.format("%-30s done: %-21s assigned: %-20s", t.name, timedeltatostr(t.done - date), t.date))
	end
end
-- ─── Task creation ────────────────────────────────────────────────────────────

local function createTask(task, date, repeats)
	return {
		name = task.name(date, repeats),
		date = datetoint(date),
		finish = task.finishdelta(date),
		show = task.showdelta(date),
		desc = task.description(date),
		due = datetoint(task.duetime(date)),
		prio = task.importance(date),
		ver = task.version(date),
		num = repeats,
	}
end

local function getAllUndone(tasks, done)
	done = done or {}
	local donetasks = {}
	for _, d in ipairs(done) do
		donetasks[d.name] = donetasks[d.name] or {}
		if donetasks[d.name][d.date] then
			donetasks[d.name][d.date] = 1 + donetasks[d.name][d.date]
		else
			donetasks[d.name][d.date] = 1
		end
	end
	local undone = {}
	for _, i in ipairs(tasks) do
		if donetasks[i.name] and donetasks[i.name][i.date] > 0 then
			donetasks[i.name][i.date] = donetasks[i.name][i.date] - 1
		else
			table.insert(undone, i)
		end
	end
	return undone
end

local function getAllDue(date, tasks)
	local due = {}
	for _, value in ipairs(tasks) do
		if inttodate(value.date) - value.show <= date then
			table.insert(due, value)
		end
	end
	return due
end

local function getUnfinished(date, tasks) -- this function for sure works btw i checked
	local unfinished = {}
	for _, value in ipairs(tasks) do
		if inttodate(value.due) + value.finish >= date or (value.finish == 0) then
			table.insert(unfinished, value)
		end
	end
	return unfinished
end

-- TODO: implement lookahead/foresight, and make things not disappear or whatever
local function getToDo(date, tasks, done)
	return getUnfinished(date, getAllUndone(getAllDue(date, tasks), done))
	-- return getAllUndone(getUnfinished(date, getAllDue(date, tasks)), done)
end

local function getDoneToday(date, done)
	local donetoday = {}
	for _, value in ipairs(done) do
		if date - 86400 <= value["done"] then
			table.insert(donetoday, value)
		end
	end
	return donetoday
end

local function getUpcoming(date)
	-- pass
end

local function getAll()
	-- pass
end

local function getDoneToFullTasks() -- could make this function be implemented in get all done
	-- pass
end

-- ─── Evaluation ───────────────────────────────────────────────────────────────

local function evaluate(task)
	local taskdicts = {}
	local check = task.checkstart()
	local checkend = task.checkend(check)
	local checkrepeats = task.checkrepeats(check, -1)
	local repeats = 0

	if #task.conditions == 0 then
		table.insert(taskdicts, createTask(task, check, repeats))
		return taskdicts
	end

	while checkend >= check and checkrepeats ~= 0 do
		local all = true
		for _, fn in ipairs(task.conditions) do
			if not fn(check) then
				all = false
				break
			end
		end
		if all then
			table.insert(taskdicts, createTask(task, check, repeats))
			checkrepeats = task.checkrepeats(check, checkrepeats)
			repeats = repeats + 1
		end
		check = check + task.checkstep(check)
	end

	return taskdicts
end

local function getTasks(tasks)
	tasks = tasks or {}
	local tasklist = {}
	for _, task in ipairs(tasks) do
		local evaluated = evaluate(task)
		for _, t in ipairs(evaluated) do
			table.insert(tasklist, t)
		end
	end
	return tasklist
end

-- ─── Exports ──────────────────────────────────────────────────────────────────

return {
	getDue = getDue,
	getAssigned = getAssigned,
	getPercentageDone = getPercentageDone,
	sortByDue = sortByDue,
	taskDictShorten = taskDictShorten,
	createTask = createTask,
	getToDo = getToDo,
	getTasks = getTasks,
	evaluate = evaluate,
	getAllUndone = getAllUndone,
	getAllTodo = getAllTodo,
	getUpcoming = getUpcoming,
	getAll = getAll,
	-- getAllDone = getAllDone,
	getAllDoneToday = getAllDoneToday,
	getDoneToFullTasks = getDoneToFullTasks,
	getAllDue = getAllDue,
	shortDictPrint = shortDictPrint,
	getUnfinished = getUnfinished,
	getDoneToday = getDoneToday,
	doneTaskPrint = doneTaskPrint,
}
