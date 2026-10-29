#!/usr/bin/env bash
# vim: ft=bash
alias psql="PAGER='nvim --clean -R' psql"

# usage: codoo [init] [db] [shell] [dev] [paths DIR,DIR...] [-- extra odoo-bin args]
# ODOO_PATH overrides the odoo checkout; PREFIX is prepended to the command (e.g. PREFIX=echo).
codoo() {
  local odoo_path=${ODOO_PATH:-$HOME/dev/repos/odoo}
  local python=$odoo_path/.venv/bin/python
  [[ -x $python ]] || python=python3

  systemctl is-active --quiet postgresql || sudo systemctl start postgresql || return

  local addons_path=$odoo_path/addons,$odoo_path/odoo/addons
  local subcmd=() args=()

  # Add a dir to the addons path if it holds at least one module (a subdir with a manifest).
  _codoo_add_path() {
    local path
    path=$(realpath "$1") || return
    [[ ,$addons_path, == *,$path,* ]] && return
    compgen -G "$path/*/__manifest__.py" >/dev/null && addons_path+=",$path"
  }
  _codoo_add_path .

  while (($#)); do
    case $1 in
      init)  args+=(-i all) ;;
      db)    args+=(-d "$(basename "$PWD")") ;;
      shell) subcmd=(shell) ;;
      dev)   args+=(--dev=xml,reload,qweb,pdb,werkzeug) ;;
      paths)
        shift
        local dir
        for dir in ${1//,/ }; do _codoo_add_path "$dir"; done
        ;;
      --) shift; break ;;
      *) break ;;
    esac
    shift
  done
  unset -f _codoo_add_path

  # the subcommand (shell) must be odoo-bin's first argument
  $PREFIX "$python" "$odoo_path/odoo-bin" "${subcmd[@]}" -D "$PWD/.cache/odoo" \
    "${args[@]}" --addons-path="$addons_path" "$@"
}

conda-activate() {
  eval "$(/home/nexus/miniconda3/bin/conda shell.bash hook)"
}

alias 'git-state'='git status -s; git submodule status'

flutter-dev-start() {
  if [[ $(tmux list-panes | wc -l) -gt 1 ]]; then
    echo "A window must only have 1 pane"
    return 1
  fi

  if [[ ! -d "$PWD/lib/" ]]; then
    echo "Is this cwd a flutter project?"
    return 1
  fi

  local window_name="flutter-dev"
  tmux rename-window "$window_name"

  local current_session=$(tmux display-message '#S')
  local window="$current_session:$window_name"
  local run_flutter="flutter run"
  local run_hot_reload="r"

  tmux split-pane
  tmux send-keys -t "$window.2" "$run_flutter" Enter

  while read file; do
    if [[ "$file" = *.dart ]]; then
      tmux send-keys -t "$window.2" "$run_hot_reload" Enter
    fi
  done < <(inotifywait -m -r -e modify,create,delete --format '%w%f' --include '.*\.dart$' "$PWD/lib")
}
