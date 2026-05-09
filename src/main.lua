-- TODO: nix run ignore env to try and isolate dependancies
-- TODO: logseq todo
-- TODO: RSS FEED THIS BITCH
-- TODO: lsp for the .config taskmanger, could use project specific nvim configuration like exrc vimrc or whatever, neodev too
-- TODO: I could maybe use reactjs
-- TODO: add ical support
-- os.execute: run command, just get exit code
local function superWait()
	local gumspins =
		{ "line", "dot", "minidot", "jump", "pulse", "points", "globe", "moon", "monkey", "meter", "hamburger" }
	for _, value in ipairs(gumspins) do
		os.execute("gum spin -s " .. value .. " --title 'Loading...' -- sleep 1")
	end
end

local function run(label, cmd, type)
	type = type or "dot"
	return os.execute("gum spin --spinner " .. type .. " --title '" .. label .. "' -- " .. cmd)
end

local lfs = require("lfs")
local viddytime = 5
local category = ""
local quick = false
local configrepo = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/taskmanger/" -- TODO: changable config repo
local cacherepo = (os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")) .. "/taskmanger/"
local localrepo = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/taskmanger/"
for index, value in ipairs(arg) do
	if value == "-t" then
		viddytime = tonumber(arg[index + 1]) -- TODO: Wrap viddy in a xdg config home, so that I can point the config file somewhere or in my flake i wrap my entire lua script in a xdg config home pointer
	end
	if value == "-c" then
		category = arg[index + 1]
	end
	if value == "-q" then
		if arg[index + 1] then
			quick = true
		end
	end
end

local src = debug.getinfo(1, "S").source:match("^@(.+)$")
src = src and (src:match("^(.+)[/\\][^/\\]+$") or ".") or "."
lfs.chdir(src)

local function doView()
	os.execute("{ lua ./view.lua " .. category .. "; } 2>&1")
end
local function doViddy()
	os.execute("viddy -n " .. viddytime .. ' "{ time lua ./view.lua ' .. category .. '; } 2>&1"')
end

local function doNvim() -- TODO: make entire front end configurable, through like init.lua or smth
	local originaldir = lfs.currentdir()
	lfs.chdir(cacherepo)
	doView()
	os.execute("clear")
	os.execute("prettier --config " .. originaldir .. "/../.prettierrc --write ./*json >/dev/null")
	os.execute("nvim -O json/todo.json " .. configrepo .. "done.json")
	lfs.chdir(originaldir)
	doView()
	lfs.chdir(originaldir) -- TODO: this is stupid as fuck
	os.execute("clear")
end

local function doCantDone()
	local originaldir = lfs.currentdir()
	lfs.chdir(cacherepo)
	doView()
	os.execute("clear")
	os.execute("prettier --config " .. originaldir .. "/../.prettierrc --write ./*json >/dev/null")
	os.execute("nvim -O json/todo.json " .. configrepo .. "cantdone.json")
	lfs.chdir(originaldir)
	doView()
	lfs.chdir(originaldir)
	os.execute("clear")
end
local function doQuitCommit()
	local originaldir = lfs.currentdir()
	lfs.chdir(configrepo)
	if not os.execute("git diff --quiet HEAD done.json") then
		if os.execute("gum confirm 'Do you really wish to Commit?'") then
			os.execute("git restore --staged :/")
			os.execute("git add done.json")
			os.execute('git commit -m "feat: changed done.json"')
			os.execute("git push")
			lfs.chdir(originaldir)
			os.exit(0)
		else
			lfs.chdir(originaldir)
		end
	else
		lfs.chdir(originaldir)
		os.exit(0)
	end
end

local function doChangeTime()
	local time = io.popen("gum input --placeholder 'Enter interval'")
	if time then
		viddytime = time:read("*a"):gsub("\n", "")
		time:close()
	end
end

local function doChangeCategory()
	local inpstring = io.popen("gum input --placeholder 'Enter Category'")
	if inpstring then
		category = inpstring:read("*a"):gsub("\n", "")
		inpstring:close()
	end
end
local function doEditTasks()
	local originaldir = lfs.currentdir()
	lfs.chdir(configrepo)
	os.execute("mkdir -p " .. localrepo .. "")
	os.execute("ln -sf " .. originaldir .. " " .. localrepo .. "")
	os.execute("nvim ./tasks/")
	if
		not os.execute("git diff --quiet HEAD ./tasks/")
		and os.execute("gum confirm 'Do you wish to Commit and Push?'")
	then
		os.execute("git restore --staged :/")
		os.execute("git add ./tasks/")
		os.execute("git commit -m 'feat: changed ./tasks'")
		os.execute("clear")
		if run("Pushing...", "git push", "pulse") then
			lfs.chdir(originaldir)
		else
			print("Push Failed")
			os.exit(1)
		end
	else
		lfs.chdir(originaldir)
	end
	dofile("view.lua")
	lfs.chdir(originaldir) --TODO: yes this is still stupid
	os.execute("clear")
end

local function exit(func) --TODO: this function is getting a lil big
	local handle = io.popen(
		"gum choose 'Nvim' 'Quit (Commit)' 'Viddy' 'Quit (Dry)' 'Change Time' 'Change Category' 'Nvim(cantDo)' 'Edit Tasks'"
	)
	if handle then
		local choice = handle:read("*a"):gsub("\n", "")
		handle:close()
		if choice == "Nvim(cantDo)" then
			doCantDone()
			func()
		end
		if choice == "Viddy" then
			func()
		end
		if choice == "Nvim" then
			doNvim()
			exit(func)
		end
		if choice == "Quit (Commit)" then
			doQuitCommit()
			exit(func)
		end
		if choice == "Quit (Dry)" then
			os.exit(0)
		end
		if choice == "Change Time" then
			doChangeTime()
			func()
		end
		if choice == "Change Category" then
			doChangeCategory()
			func()
		end
		if choice == "Edit Tasks" then
			doEditTasks()
			exit(func)
		end
	end
end
local function doTodo()
	doViddy()
	-- TODO: i could make view.lua or some other shitty lua that just prints the a function in view or main so that
	-- we get real time smth idk i don't like not being able to pipe to viddy
	os.execute("clear")
	if quick then
		doNvim()
	end
	exit(doTodo)
end
doTodo()
-- NOTE: this code is handling what it would look like to add a line to todo without nvim
-- os.execute("prettier --write ../*json >/dev/null")
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
