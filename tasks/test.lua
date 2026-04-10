local m = require("src.model")
local st = m.singleTasks
local weeklyTask = m.weeklyTask
local dt = m.dt
local timedelta = m.timedelta
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
	}),
	wt("shave"),
	wt("check emails"),
	wt("cut nails"),
}
