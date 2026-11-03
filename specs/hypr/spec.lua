return {
	package("hyprland"),
	file.link("~/.config/hypr"),
	requires({
		"hyprpicker",
		"awww",
		"hyprshot",
		"cliphist",
	}),
}
