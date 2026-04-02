local utils = require("plugins.utils")

---@class Plugin
return {
  name = "aur",
  summary = "Arch User Repository",
  actions = {
    aur = {
      plan = function() end,
      exec = function(output)
        -- local function get_package_list(repodir)
        --   local get_pkg_files = ("cd %s && makepkg --packagelist"):format(repodir)
        --   local raw_packages = get_command_output(get_pkg_files)
        --   local packages_list = string_split(raw_packages, "\n")
        --   for i, pkg in ipairs(packages_list) do
        --     packages_list[i] = "./" .. string.sub(pkg, #repodir + 2)
        --   end
        --   return packages_list
        -- end

        -- local function install2(repodir)
        --   local build_command = ("cd %s && makepkg -s"):format(repodir)
        --   local success, exitcode, code = os.execute(build_command)

        --   -- code == 13 means "A package has already been built." - man makepkg #ERRORS
        --   if (exitcode == "exit" and code == 13) or success then
        --     local packages = table.concat(get_package_list(repodir), " ")
        --     local install_command = ("cd %s && sudo pacman -U --needed %s"):format(repodir, packages)
        --     os.execute(install_command)
        --   end
        -- end

        local function install(repodir)
          local install_command = ("cd %s && makepkg -si --needed"):format(repodir)
          local success, _, code = os.execute(install_command)
          if success then
            print("Command failed with exit code: " .. code)
          else
            print("Command exited with exit code: " .. code)
          end
        end

        local cache_dir = contexts.env.XDG_CACHE_HOME or "/var/tmp"
        cache_dir = cache_dir .. "/comtrya/aur"

        local repodir = utils.clone_repo(output.repo, cache_dir, "--depth 1")
        if not utils.execute("sudo pacman -S --needed base-devel") then
          print("error: failed to install base-devel")
          return
        end
        install(repodir)
      end,
    },
  },
}
