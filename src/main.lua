-- This file is effectively a 'view', completing the mvc. hell you can count the bash script i made a 'view'
local json = require("dkjson")
local lfs = require("lfs")

local src = debug.getinfo(1, "S").source:match("^@(.+/)[^/]+$") or "./"
lfs.chdir(src .. "/..")
src = lfs.currentdir()

local controller = require("src/controller")
local model = require("src/model")

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
-- TODO: its in json file format, i could theoretically at least format the strings
-- or even make a gui for it

local date = os.time()

local dir = require("pl.dir")
local path = require("pl.path")
local tablex = require("pl.tablex")

local luafiles = dir.getallfiles("tasks", "*.lua")
luafiles = tablex.map(function(x)
	local no_ext = path.splitext(x)
	return no_ext:gsub("[/\\]", ".")
end, luafiles)

print_r(luafiles)
local function fileToTasks(file)
	local t = {}
	local function f(result, tasks) -- This is so fucking stupid
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
local modeltasks = {}
for _, value in ipairs(luafiles) do -- TODO: fuycking imperitive programming
	print(value)
	for _, task in ipairs(fileToTasks(require(value))) do

		table.insert(modeltasks, task)
		
	end
end

local tasks = controller.getTasks(modeltasks)
local donefile = openfile("done.json")
local done = {}
for _, value in ipairs(donefile) do
	table.insert(done, { name = value[1], date = value[2], done = value[3] })
end

local todo = controller.getToDo(date, tasks, done)
todo = controller.sortByDue(todo)

local shortened = {}
for _, t in ipairs(todo) do
	local s = controller.taskDictShorten(t, date)

	if type(s) == "table" and next(s) ~= nil then
		table.insert(shortened, s)
	end
end
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
