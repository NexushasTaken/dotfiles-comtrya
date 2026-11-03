return {
	package("hyprland"),
	file.link("~/.config/hypr"),
	requires({
		"hyprpicker",
		"awww",
		"hyprshot",
		"cliphist",
		["network-manager-applet"] = {
			why = "Network Manager systray",
		},
		["udisks2"] = {
			why = "auto-mounting disk",
		},
		["udiskie"] = {
			why = "auto-mounting disk notification and systray",
		},
	}),
}
