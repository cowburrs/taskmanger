local funcs = require("src/funcs")

-- ─── Datetime helper ──────────────────────────────────────────────────────────

local function dt(year, month, day, hour, min, sec)
	return os.time({ year = year, month = month, day = day, hour = hour or 0, min = min or 0, sec = sec or 0 })
end

local DAY = 86400
local HOUR = 3600
local MIN = 60

local function timedelta(days, hours, minutes, weeks, seconds)
	return (days or 0) * DAY + (hours or 0) * HOUR + (minutes or 0) * MIN + (weeks or 0) * DAY * 7 + (seconds or 0)
end

-- ─── Condition helpers ────────────────────────────────────────────────────────

local function isDateTime(day)
	return function(date)
		return day == date
	end
end

local function isHour(hour)
	return function(date)
		return hour == os.date("*t", date).hour
	end
end

local function isAbsWeek(w)
	return function(date)
		return w == funcs.absweek(date)
	end
end

local function isNot(func)
	return function(x)
		return not func(x)
	end
end

local function isNotTeachingBreak()
	return function(date)
		local aw = funcs.absweek(date)
		return aw ~= 2936 and aw ~= 2937
	end
end

local function isDayWeek(dayslist)
	return function(date)
		local dow = funcs.dayofweek(date)
		for _, x in ipairs(dayslist) do
			if dow == (x % 7) then
				return true
			end
		end
		return false
	end
end

local function isDayOfWeek(day)
	return function(date)
		return funcs.dayofweek(date) == (day % 7)
	end
end

-- ─── Core helpers ─────────────────────────────────────────────────────────────

local function just(x) -- ITS A FUCKING POLYMORPHIC FUNCTION XDDDDDDDDDDDDDDDDDDDDDDD
	return function(...)
		return x
	end
end

local function checkEndDefault()
	return function(x)
		return x + 100 * 365 * DAY
	end
end

local function dueTimeDefault()
	return function(x)
		return x
	end
end

local function dueTime(delta)
	return function(x)
		return x + delta
	end
end

local function dueIn(days, hours, minutes, weeks, seconds)
	local delta = timedelta(days, hours, minutes, weeks, seconds)
	return function(x)
		return x + delta
	end
end

local function dueOn(date)
	return function(_)
		return date
	end
end

local function listToTextbook(l)
	local result = {}
	for x = 1, #l do
		for y = 1, l[x] do
			table.insert(result, x .. "." .. y)
		end
	end
	return result
end

local function justRepeats(x)
	local function repeatsN(_, n)
		if n == -1 then
			return x
		else
			return n - 1
		end
	end
	return repeatsN
end

-- ─── Task ─────────────────────────────────────────────────────────────────────

local function Task(opts)
	assert(opts.name, "Task requires a name")
	return {
		name = opts.name,
		conditions = opts.conditions or {},
		description = opts.description or just(""),
		duetime = opts.duetime or dueTimeDefault(), -- 0 means never due
		finishdelta = opts.finishdelta or just(timedelta(-1)), -- how long after it should show
		showdelta = opts.showdelta or just(timedelta(1)),
		category = opts.category or just(""),
		consecutive = opts.consecutive or just(false),
		checkstart = opts.checkstart or just(dt(2000, 1, 1)),
		checkend = opts.checkend or checkEndDefault(),
		checkstep = opts.checkstep or just(DAY), -- time between each check, so like daily or hourly, minutely is possible. secondly not implementable though can be thought of as dt
		checkrepeats = opts.checkrepeats or justRepeats(1), -- total number of repeats before it stops, -1 is inf (or any negative number, it stops at 0)
	}
end

-- ─── Task constructors ────────────────────────────────────────────────────────

local function textBookTasks(bookname, start, finish, l)
	local totalDelta = finish - start
	local textbookchaps = listToTextbook(l)
	local delta = totalDelta / #textbookchaps
	return {
		name = function(_, n)
			return bookname .. " Chapter " .. textbookchaps[n + 1]
		end,
		conditions = { just(true) },
		checkstart = just(start),
		checkrepeats = justRepeats(#textbookchaps),
		checkstep = just(delta),
	}
end

local function oneTimeTask(Name, Start, Due)
	return {
		name = just(Name),
		conditions = { isDateTime(Start) },
		duetime = dueOn(Due),
		checkstart = just(Start),
	}
end

local function lectureTask(Subject, Letter, Week, WeekDay, Start, Repeats)
	return {
		name = function(_, n)
			return Subject:sub(1, 1):upper() .. Subject:sub(2) .. " Week " .. (n + Week) .. " Lec" .. Letter:upper()
		end,
		conditions = { isDayOfWeek(WeekDay), isNotTeachingBreak() },
		duetime = dueTime(timedelta(3)),
		checkstart = just(Start),
		checkrepeats = justRepeats(Repeats),
	}
end

local function weeklyTask(name)
	return {
		name = just(name),
		conditions = { isDayOfWeek(0) },
		duetime = dueTime(timedelta(7)),
		checkstart = function(date)
			return funcs.floorToDay(date) - timedelta(7)
		end,
		checkrepeats = justRepeats(2),
		finishdelta = just(timedelta(0)),
	}
end

local function lectureTasks(Subject, Repeats, Sessions, Week)
	Week = Week or 0
	local letters = { "A", "B", "C", "D", "E", "F", "G" }
	local result = {}
	for i, session in ipairs(Sessions) do
		table.insert(result, lectureTask(Subject, letters[i], Week, session[1], session[2], Repeats))
	end
	return result
end

local function singleTasks(strs)
	local result = {}
	for _, s in ipairs(strs) do
		table.insert(result, Task({ name = just(s) }))
	end
	return result
end
--  quizTask could exist methinks
local function quizTask(subject, name, checkstart, duetime, repeats, startnum)
	startnum = startnum or 0
	return {
		name = function(_, n)
			return subject .. " Week " .. (n + startnum) .. " " .. name
		end,
		conditions = { isDayOfWeek(0), isNotTeachingBreak() },
		duetime = dueTime(duetime),
		checkstart = just(checkstart),
		checkrepeats = justRepeats(repeats),
	}
end

local function worksheetTasks(bookname, start, delta, repeats, skiplist)
	return {
		name = function(_, n)
			return bookname .. " Chapter " .. funcs.getNumSkipTable(n + 1, skiplist)
		end,
		conditions = { just(true) },
		checkstart = just(start),
		checkrepeats = justRepeats(repeats),
		checkstep = just(delta),
		consecutive = just(true),
	}
end

-- ─── Tasks list ───────────────────────────────────────────────────────────────

-- TODO: I could use gum in my cli tool, like as in to like 'you want to change add to todo' or as in like a 'do you wish to gitshit'
-- Or i could make it that when you do exit, it checks if done has been changed, and auto git add commits that. that sounds smart

return {
	DAY = DAY,
	HOUR = HOUR,
	MIN = MIN,
	timedelta = timedelta,
	dt = dt,
	isDateTime = isDateTime,
	isHour = isHour,
	isAbsWeek = isAbsWeek,
	isNot = isNot,
	isNotTeachingBreak = isNotTeachingBreak,
	isDayWeek = isDayWeek,
	isDayOfWeek = isDayOfWeek,
	just = just,
	checkEndDefault = checkEndDefault,
	dueTimeDefault = dueTimeDefault,
	dueTime = dueTime,
	dueIn = dueIn,
	dueOn = dueOn,
	justRepeats = justRepeats,
	listToTextbook = listToTextbook,
	Task = Task,
	textBookTasks = textBookTasks,
	oneTimeTask = oneTimeTask,
	lectureTask = lectureTask,
	lectureTasks = lectureTasks,
	singleTasks = singleTasks,
	quizTask = quizTask,
	worksheetTasks = worksheetTasks,
	weeklyTask = weeklyTask,
	justReturn = justReturn,
}
