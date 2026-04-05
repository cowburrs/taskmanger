-- controller.lua
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
	if t.date ~= epoch2000 then
		return timedeltatostr(inttodate(t.date) - date)
	else
		return "N/A"
	end
end

local function getPercentageDone(t, date) -- TODO: This doesnt work
	if t.date ~= t.due then
		return (datetoint(date) - t.date) / (t.due - t.date)
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
-- TODO: Add percentage, percentage time of due date done, so if half of due date has been exhausted then 50%
local function taskDictShorten(t, date)
	local taskdict = {
		name = t.name,
		due = getDue(t, date),
		assigned = getAssigned(t, date),
	}
	if t.desc ~= "" then
		taskdict.desc = t.desc
	end
	-- TODO: I dont want this to show all the time
	taskdict["%"] = math.floor(getPercentageDone(t, date) * 100)
	taskdict.date = t.date
	return taskdict
end

-- ─── Task creation ────────────────────────────────────────────────────────────

local function createTask(task, date, repeats)
	return {
		name = task.name(date, repeats),
		date = datetoint(date),
		desc = task.description(date),
		due = datetoint(task.duetime(date)),
		prio = task.importance(date),
		ver = task.version(date),
		num = repeats, -- num repeats
	}
end

-- TODO: i just had the best fucking idea ever, how about instead of parsing into done
-- I make it create another json, donetasks.json, with donetasks but in proper format
-- so i dont have to kill myself again and again
local function getAllUndone()
	-- pass
end

-- TODO: implement lookahead/foresight, and make things not disappear or whatever
local function getToDo(date, tasks, done)
	local todo = {}
	local donetasks = {}

	for _, d in ipairs(done) do
		donetasks[d.name] = donetasks[d.name] or {}
		donetasks[d.name][d.date] = true
	end

	for _, i in ipairs(tasks) do
		if inttodate(i.date) <= date and not (donetasks[i.name] and donetasks[i.name][i.date]) then
			table.insert(todo, i)
		end
	end

	return todo
end

local function getAllTodo(date) -- TODO: print all even not done
	-- pass
end

local function getUpcoming(date)
	-- pass
end

local function getAll()
	-- pass
end

local function getAllDone()
	-- pass
end

local function getAllDoneToday() -- could make this function be implemented in get all done
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
	getAllDone = getAllDone,
	getAllDoneToday = getAllDoneToday,
	getDoneToFullTasks = getDoneToFullTasks,
}
