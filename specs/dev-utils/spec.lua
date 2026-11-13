return spec({
	depends("lazygit", "gdb", "tmux", "inputrc", "git", "gh", "foot", "cargo", "bash", "clang-format"),
	requires({
		"eza",
		"zoxide",
		"fzf",
		"wget",
		"xdg-user-dirs",
		"caja",
		"devhelp",
		"rsync",
		"tldr",
		"unzip",
		"zip",
	}),
})
