-- funcs.lua
local os = os
local math = math

-- ─── General helpers ─────────────────────────────────────────────────────────────

function print_r(t, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent)
	if type(t) == "table" then
		local keys = {}
		for k in pairs(t) do
			table.insert(keys, k)
		end
		table.sort(keys, function(a, b)
			if type(a) == type(b) then
				return a < b
			end
			return tostring(a) < tostring(b)
		end)
		for _, k in ipairs(keys) do
			local v = t[k]
			if type(v) == "table" then
				print(prefix .. "[" .. tostring(k) .. "] =>")
				print_r(v, indent + 1)
			else
				print(prefix .. "[" .. tostring(k) .. "] => " .. tostring(v))
			end
		end
	else
		print(prefix .. tostring(t))
	end
end

-- Source - https://stackoverflow.com/a/27028488
-- Posted by hookenz, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-04-04, License - CC BY-SA 4.0

function dump(o)
	if type(o) == "table" then
		local keys = {}
		for k in pairs(o) do
			table.insert(keys, k)
		end
		table.sort(keys, function(a, b)
			if type(a) == type(b) then
				return a < b
			end
			return tostring(a) < tostring(b)
		end)
		local s = "{"
		for _, k in ipairs(keys) do
			local v = o[k]
			local fk = type(k) ~= "number" and '"' .. k .. '"' or k
			s = s .. "" .. fk .. " = " .. dump(v) .. ", "
		end
		return s .. "} "
	else
		return tonumber(o) and tostring(o) or '"' .. tostring(o) .. '"'
	end
end

local function spread(t, into)
	for _, v in ipairs(t) do
		table.insert(into, v)
	end
end
-- ─── Date helpers ─────────────────────────────────────────────────────────────

local function dayofyear(date)
	local start = os.time({ year = os.date("*t", date).year, month = 1, day = 1, hour = 0, min = 0, sec = 0 })
	return math.floor((date - start) / 86400) + 1
end

local function datetoint(date, timed)
	timed = timed or 0
	return tonumber(os.date("%Y%m%d%H%M", date + timed))
end

local function inttodate(n)
	local s = tostring(n)
	local year = tonumber(s:sub(1, 4))
	local month = tonumber(s:sub(5, 6))
	local day = tonumber(s:sub(7, 8))
	local hour = tonumber(s:sub(9, 10))
	local min = tonumber(s:sub(11, 12))
	return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = 0 })
end

local function timedeltatostr(td)
	local total_seconds = math.floor(td)
	local sign = ""
	if total_seconds < 0 then
		sign = "-"
		total_seconds = -total_seconds
	end
	local days = math.floor(total_seconds / 86400)
	local hours = math.floor((total_seconds % 86400) / 3600)
	local minutes = math.floor((total_seconds % 3600) / 60)
	local seconds = total_seconds % 60
	if total_seconds > 86400 then
		return sign .. days .. " Days, " .. hours .. " Hours"
	elseif total_seconds > 3600 then
		return sign .. hours .. " Hours, " .. minutes .. " Minutes"
	elseif total_seconds > 60 then
		return sign .. minutes .. " Minutes, " .. seconds .. " Seconds"
	else
		return sign .. seconds .. " Seconds"
	end
end

local function hour(date)
	return os.date("*t", date).hour
end

local function dayofweek(date)
	return (os.date("*t", date).wday - 2)
end

local function absweek(date)
	local epoch = os.time({ year = 1969, month = 12, day = 29, hour = 0, min = 0, sec = 0 })
	return math.floor((date - epoch) / (7 * 86400))
end

local function week(date)
	-- ISO week number
	return tonumber(os.date("%V", date))
end

local function year(date)
	return os.date("*t", date).year
end

local function month(date)
	return os.date("*t", date).month
end

local function day(date)
	return date/86400
end

local function weekofmonth(date)
	return math.floor((os.date("*t", date).day - 1) / 7) + 1
end

local function islastdayofyear(date)
	local t = os.date("*t", date)
	return t.month == 12 and t.day == 31
end

local function daysInMonth(y, m)
	-- day 0 of next month = last day of this month
	return os.date("*t", os.time({ year = y, month = m + 1, day = 0, hour = 0, min = 0, sec = 0 })).day
end

local function islastdayofmonth(date)
	local t = os.date("*t", date)
	return t.day == daysInMonth(t.year, t.month)
end

local function daystoendofmonth(date)
	local t = os.date("*t", date)
	return daysInMonth(t.year, t.month) - t.day
end

local function daystoendofyear(date)
	local t = os.date("*t", date)
	local dec31 = os.time({ year = t.year, month = 12, day = 31, hour = 0, min = 0, sec = 0 })
	return math.floor((dec31 - date) / 86400)
end

-- NOTE: no holidays library in Lua, pass in a table of "YYYY-MM-DD" strings
local function ispublicholiday(date, holidaylist)
	local datestr = os.date("%Y-%m-%d", date)
	for _, h in ipairs(holidaylist) do
		if h == datestr then
			return true
		end
	end
	return false
end

local function ifhelper(a, b, c)
	if a then
		return b
	else
		return c
	end
end

-- ─── Exports ──────────────────────────────────────────────────────────────────

return {
	dump = dump,
	dayofyear = dayofyear,
	datetoint = datetoint,
	inttodate = inttodate,
	timedeltatostr = timedeltatostr,
	hour = hour,
	dayofweek = dayofweek,
	absweek = absweek,
	week = week,
	year = year,
	month = month,
	weekofmonth = weekofmonth,
	islastdayofyear = islastdayofyear,
	islastdayofmonth = islastdayofmonth,
	daystoendofmonth = daystoendofmonth,
	daystoendofyear = daystoendofyear,
	ispublicholiday = ispublicholiday,
	ifhelper = ifhelper,
	spread = spread,
	day = day,
}
