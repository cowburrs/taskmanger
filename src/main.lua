-- os.execute: run command, just get exit code
local gumspins =
	{ "line", "dot", "minidot", "jump", "pulse", "points", "globe", "moon", "monkey", "meter", "hamburger" }
for _, value in ipairs(gumspins) do
	-- os.execute("gum spin -s " .. value .. " --title 'Loading...' -- sleep 0.5")
end
local lfs = require("lfs")

-- local src = debug.getinfo(1, "S").source:match("^@(.+)$")
-- lfs.chdir(src .. "/..")
-- src = lfs.currentdir()
local src = debug.getinfo(1, "S").source:match("^@(.+)$")
src = src:match("^(.+)[/\\][^/\\]+$")
lfs.chdir(src)
package.path = package.path .. ";../src/?.lua"
require("funcs")
print_r(arg)

local function doTodo()
	os.execute("viddy -n " .. arg[1] .. ' "{ time lua ./view.lua; } 2>&1"')
	os.execute("prettier --write ../*json >/dev/null")
	os.execute("nvim ../json/todo.json")
	os.execute("nvim ../done.json")
	local handle = io.popen("gum choose 'Quit' 'Again'")
	if handle then
		local choice = handle:read("*a"):gsub("\n", "")
		handle:close()
		if choice == "Again" then
			doTodo()
		end
		if choice == "Quit" then
			os.exit(0)
		end
		print(choice)
	end
end
doTodo()
