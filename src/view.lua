-- This file is effectively a 'view', completing the mvc. hell you can count the bash script i made a 'view'
-- technically i think this is controller or whatveer but lets not worry
local json = require("dkjson")
local lfs = require("lfs")

local src = debug.getinfo(1, "S").source:match("^@(.+/)[^/]+$") or "./"
lfs.chdir(src .. "/..")
src = lfs.currentdir()

local controller = require("src.controller")
local model = require("src.model")

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

local function fileToTasks(file)
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

local function filesToTasks(files)
	local tasks = {}
	for _, value in ipairs(files) do
		for _, task in ipairs(fileToTasks(require(value))) do
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

local date = os.time()

local dir = require("pl.dir")

local luafiles = dir.getallfiles("tasks", "*.lua")
local modules = filesToModules(luafiles)

local modeltasks = filesToTasks(modules)

local tasks = controller.getTasks(modeltasks, date)
local done = taskShorten(openfile("done.json"))

local todo = controller.sortByDue(controller.getToDo(date, tasks, done))

local shortened = tasksToReadables(todo, date)

controller.shortDictPrint(shortened)

print()
print("-| Done Today |-")
controller.doneTaskPrint(controller.getDoneToday(date, done), date)

table.insert(shortened, { name = "End of Todo", date = 0 })
local todofile = {}
for _, value in ipairs(shortened) do
	table.insert(todofile, { value["name"], value["date"], date })
end
writefile("json/todo.json", todofile)
writefile("json/tasks.json", tasks)
-- tf:write(json.encode(shortened))
--
