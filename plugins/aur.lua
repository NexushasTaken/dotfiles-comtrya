---@class Plugin
return {
  name = "aur",
  summary = "Arch User Repository",
  actions = {
    aur = {
      plan = function() end,
      exec = function(output)
        local function dir_exist(dirpath)
          local command = ("cd %s"):format(dirpath)
          local success, _, _ = os.execute(command)
          return success == true
        end

        local function is_git_repo(dirpath)
          local command = ("cd %s && git rev-parse --is-inside-work-tree"):format(dirpath)
          local success, _, _ = os.execute(command)
          return success == true
        end

        local basename = output.repo:match("([^/]+)$")
        local repodir = ("/var/tmp/%s"):format(basename)
        os.execute("sudo pacman -S --needed base-devel git")

        if dir_exist(repodir) then
          if not is_git_repo(repodir) then
            print(("Error: %s is not a valid git repository."):format(repodir))
          end
        else
          local clone = ("git clone %s %s"):format(output.repo, basename, repodir)
          os.execute(clone)
        end

        local build_command = ("cd %s && makepkg -s"):format(repodir)
        local install_command = ("cd %s && makepkg -i --needed --noconfirm"):format(repodir)
        local success, exitcode, code = os.execute(build_command)
        -- code == 13 means "A package has already been built." - man makepkg #ERRORS
        if (exitcode == "exit" and code == 13) or success then
          os.execute(install_command)
        end
      end,
    },
  },
}
