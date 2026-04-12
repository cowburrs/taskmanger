-- os.execute: run command, just get exit code
local function superWait()
	local gumspins =
		{ "line", "dot", "minidot", "jump", "pulse", "points", "globe", "moon", "monkey", "meter", "hamburger" }
	for _, value in ipairs(gumspins) do
		os.execute("gum spin -s " .. value .. " --title 'Loading...' -- sleep 1")
	end
end
local lfs = require("lfs")
arg[1] = arg[1] or 5

local src = debug.getinfo(1, "S").source:match("^@(.+)$")
src = src:match("^(.+)[/\\][^/\\]+$")
lfs.chdir(src)

local function exit(func)
	local handle = io.popen("gum choose 'Nvim' 'Quit (Commit)' 'Viddy' 'Quit (Dry)' 'Change Time' 'Wait'")
	if handle then
		local choice = handle:read("*a"):gsub("\n", "")
		handle:close()
		if choice == "Viddy" then
			func()
		end
		if choice == "Nvim" then
			os.execute("lua ./view.lua;")
			os.execute("clear")
			os.execute("prettier --write ../*json >/dev/null")
			os.execute("nvim -O ../json/todo.json ../done.json")
			exit(func)
		end
		if choice == "Quit (Commit)" then
			if not os.execute("git diff --quiet HEAD ../done.json") then
				if os.execute("gum confirm 'Do you really wish to Commit?'") then
					os.execute("git restore --staged :/")
					os.execute("git add ../done.json")
					os.execute("git commit -m 'feat: changed done.json'")
					os.execute("git push")
					os.exit(0)
				else
					exit(func)
				end
			else
				os.exit(0)
			end
		end
		if choice == "Quit (Dry)" then
			os.exit(0)
		end
		if choice == "Change Time" then
			local time = io.popen("gum input --placeholder 'Enter interval'")
			if time then
				arg[1] = time:read("*a"):gsub("\n", "")
				time:close()
			end
			func()
		end
		if choice == "Wait" then
			superWait()
			exit(func)
		end
	end
end
local function doTodo()
	os.execute("viddy -n " .. arg[1] .. ' "{ time lua ./view.lua; } 2>&1"')
	os.execute("clear")
	exit(doTodo)
end
doTodo()
-- NOTE: this code is handling what it would look like to add a line to todo without nvim
-- local handle = io.popen("cat ../json/todo.json | head -n -2 | tail -n +2 | gum filter")
-- if handle then
-- 	local choice = handle:read("*a"):gsub("\n", "")
-- 	handle:close()
-- 	-- os.execute('sed -i "2i ' .. choice .. '" ../done.json')
-- 	if not (choice == "") then
-- 		print("sed -i '2i " .. choice .. "' ../done.json")
-- 	else
-- 		os.exit(0)
-- 	end
-- end
