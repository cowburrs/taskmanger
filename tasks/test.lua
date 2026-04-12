local m = require("src.model")
local funcs = require("src.funcs")
local st = m.singleTasks
local wt = m.weeklyTask
return {
	st({
		"Test works",
		"bin scripts instead of hypr nixos",
		"neovim config (vim pack) treesit (ctrl backspace)",
		"declarative flatpak/roblox",
		"lua library lsp lazydev",
		"millenium nix",
		"steam notifications wayland work",
		"humble bundle tasks",
		"Stitch pants",
		"cadetship",
		"git fetch to burrsgs",
		"vanguard stocks",
		"move games to wishlist steam",
		"clean megumin pillow",
		"wakeup checklist",
		"anu cssa",
		"Integrate gaussian distribution e^-x^2",
		"Proportional derivative controller engn",
		"vpython nix",
		"Go through emails",
		"gum cli addage to todo",
		"Go through all todo in taskmanger",
		"bsides/csides canberra",
		"Ctrl Backspace nvim",
	}),
	wt("shave"),
	wt("clean"),
	wt("check emails"),
	wt("cut nails"),
	wt("clear tabs"),
	wt("nix flake update"),
	{
		name = m.just("Humble Bundle"),
		conditions = { m.isDayOfWeek(2), m.isWeekOfMonth(1, m.timedelta(0, -17)) },
		-- -17 cause PST is 17 hours behind my time zone, its actually wednesday too
		duetime = m.dueTime(m.timedelta(30)),
		checkstart = function(date)
			return funcs.floorToDay(date) - m.timedelta(31) + m.timedelta(0, 3)
			-- 3 hours cause 3 am
		end,
		checkrepeats = m.justRepeats(2),
		finishdelta = m.just(m.timedelta(0)),
	},
}
