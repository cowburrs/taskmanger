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

local done = openfile("done.json")

local modeltasks = {}
local dir = require("pl.dir")
local luafiles = dir.getallfiles("tasks", "*.lua")
for index, value in ipairs(require("tasks.school")) do
	table.insert(modeltasks, model.Task(value))
end


local tasks = controller.getTasks(modeltasks)

local todo = controller.getToDo(date, tasks, done)
todo = controller.sortByDue(todo)

local shortened = {}
for _, t in ipairs(todo) do
	local s = controller.taskDictShorten(t, date)

	if type(s) == "table" and next(s) ~= nil then
		table.insert(shortened, s)
	end
	print(dump(s))
end

table.insert(shortened, { name = "End of Todo", date = 0 })

writefile("json/todo.json", shortened)
-- tf:write(json.encode(shortened))
--
