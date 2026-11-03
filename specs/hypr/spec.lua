return {
	package("hyprland"),
	file.link("~/.config/hypr"),
	requires({
		"hyprpicker",
		"awww",
		"hyprshot",
		"cliphist",
		"network-manager-applet",
		["udisks2"] = {
			why = "auto-mounting disk",
		},
		["udiskie"] = {
			why = "auto-mounting disk notification and systray",
		},
	}),
}
