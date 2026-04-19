-- This file is effectively a 'view', completing the mvc. hell you can count the bash script i made a 'view'
-- technically i think this is controller or whatveer but lets not worry
local json = require("dkjson")
local lfs = require("lfs")

local src = debug.getinfo(1, "S").source:match("^@(.+/)[^/]+$") or "./"
lfs.chdir(src .. "/..")
src = lfs.currentdir()

local controller = require("src.controller")
local model = require("src.model")
local funcs = require("src.funcs")

local function writefile(file, table)
	local tf = io.open(file, "w")
	if tf then
		tf:write(json.encode(table))
		tf:close()
	end
end

local function openfile(file)
	local df = io.open(file, "r")
	if df then
		local contents = df:read("*a")
		df:close()
		return json.decode(contents) or {}
	else
		return {}
	end
end

local function moduleToTask(file)
	local t = {}
	local function f(result, tasks) -- This is so fucking stupid all for functional programming
		for _, value in ipairs(tasks) do
			if type(value) == "table" then
				if value.name then
					table.insert(result, model.Task(value))
				else
					f(result, value)
				end
			end
		end
	end
	f(t, file)
	return t
end

local function modulesToTasks(files)
	local tasks = {}
	for _, value in ipairs(files) do
		for _, task in ipairs(moduleToTask(require(value))) do
			task.category = model.just(value)
			table.insert(tasks, task)
		end
	end
	return tasks
end

local function filesToModules(files)
	local path = require("pl.path")
	local tablex = require("pl.tablex")
	local modules = tablex.map(function(x)
		local no_ext = path.splitext(x)
		return no_ext:gsub("[/\\]", ".")
	end, files)
	return modules
end

local function taskShorten(dict)
	local shortDict = {}
	for _, value in ipairs(dict) do
		table.insert(shortDict, { name = value[1], date = value[2], done = value[3] })
	end
	return shortDict
end

local function tasksToReadables(tasks, date)
	local readables = {}
	for _, t in ipairs(tasks) do
		local s = controller.taskDictReadable(t, date)

		if type(s) == "table" and next(s) ~= nil then
			table.insert(readables, s)
		end
	end
	return readables
end

local function shortDictPrint(dict)
	for _, t in ipairs(dict) do
		print(string.format("[%3d%%] %-30s assigned: %-20s due: %s", t["%"], t.name, t.assigned, t.due or "N/A"))
	end
end

local function doneTaskPrint(dict, date)
	for _, t in ipairs(dict) do
		print(string.format("%-30s done: %-21s assigned: %-20s", t.name, funcs.timedeltatostr(t.done - date), t.date))
	end
end

local function toCopyDict(shortened, date)
	local copyable = {}
	local shortenedCopy = { table.unpack(shortened) } -- WARNING: shallow copy
	table.insert(shortenedCopy, { name = "End of Todo", date = 0 })
	for _, value in ipairs(shortenedCopy) do
		table.insert(copyable, { value["name"], value["date"], date })
	end
	return copyable
end

local date = os.time()
local dir = require("pl.dir")
local luafiles = dir.getallfiles("tasks", "*.lua")
local modules = filesToModules(luafiles)
local modeltasks = modulesToTasks(modules)
local tasks = controller.getTasks(modeltasks, date)
local done = taskShorten(openfile("done.json")) -- TODO: I should use json5 instead for done, its much better, then i don't have to append the stupid end of list
os.execute("fixjson cantdone.json5 > json/cantdone.json") -- TODO: THIS TAKES 0.04 fucking seconds to run
for _, value in ipairs(taskShorten(openfile("json/cantdone.json"))) do -- TODO: This is pretty hard coded icl
	table.insert(done, value)
end
local todo = controller.sortByDue(controller.getToDo(date, tasks, done))
if arg[1] then
	todo = controller.getCategory(todo, arg[1])
end
local shortened = tasksToReadables(todo, date)
shortDictPrint(shortened)
print()
print("-| Done Today |-")
doneTaskPrint(controller.getDoneToday(date, done), date)
local todofile = toCopyDict(shortened, date)

-- TODO: I should lock these behind arg so i dont have to fucking run these every time and use
-- All of my ssd utilization
writefile("json/todo.json", todofile)
writefile("json/tasks.json", tasks)
-- tf:write(json.encode(shortened))
--
