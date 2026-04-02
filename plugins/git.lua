local utils = require("plugins.utils")

---@class Plugin
return {
  name = "git",
  summary = "Git clone",
  actions = {
    git = {
      plan = function() end,
      exec = function(output)
        local directory = output.directory
        directory = directory or (contexts.env.XDG_CACHE_HOME or "/var/tmp") .. "/comtrya/clone"
        utils.clone_repo(output.repo_url, directory, output.extra_args)
      end,
    },
  },
}
