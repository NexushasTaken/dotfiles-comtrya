local M = {}

function M.execute(command)
  local success, _, _ = os.execute(command)
  return success == true
end

function M.dir_exist(dirpath)
  return M.execute(("cd %s 2> /dev/null"):format(dirpath))
end

function M.is_git_repo(dirpath)
  return M.execute(("cd %s && git rev-parse --is-inside-work-tree 1> /dev/null"):format(dirpath))
end

---@param repo_url string
---@param directory string
---@param extra_args? string
---@return string?
function M.clone_repo(repo_url, directory, extra_args)
  extra_args = extra_args or ""
  if not M.execute("mkdir -p " .. directory) then
    print("error: failed to create '" .. directory .. "' directory")
    return nil
  end

  local basename = repo_url:match("([^/]+)$")
  local repodir = ("%s/%s"):format(directory, basename)
  if not M.execute("sudo pacman -S --needed git") then
    print("error: failed to install git")
    return nil
  end

  if M.dir_exist(repodir) then
    if not M.is_git_repo(repodir) then
      print(("Error: %s is not a valid git repository."):format(repodir))
    end
  else
    local clone = ("git clone %s %s %s"):format(repo_url, repodir, extra_args)
    if not M.execute(clone) then
      print("error: failed to clone " .. repo_url)
      return nil
    end
  end

  return repodir
end

function M.string_split(inputstr, sep)
  if sep == nil then
    sep = "%s" -- Default to whitespace
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

function M.get_command_output(command)
  local handle, errmsg = io.popen(command)
  if handle == nil then
    print(("Error: %s"):format(errmsg))
    return
  end
  local result = tostring(handle:read("*a"))
  handle:close()
  return result
end


M.cache_dir = (contexts.env.XDG_CACHE_HOME or "/var/tmp") .. "/comtrya"

return M
