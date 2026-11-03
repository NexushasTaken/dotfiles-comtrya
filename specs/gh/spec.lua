return spec({
  package("github-cli"),
  file.link("config.yml", "~/.config/gh/config.yml")
})
