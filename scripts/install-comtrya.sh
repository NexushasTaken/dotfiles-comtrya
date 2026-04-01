#!/usr/bin/env bash
# TODO: make this an aur repo

aur_cache="${XDG_CACHE_HOME:-$HOME/.cache}/aur"
if [[ -n "$CACHE_DIR" ]]; then
  aur_cache="$CACHE_DIR"
fi
mkdir -p "$aur_cache"

repo="https://github.com/NexushasTaken/comtrya.git"
repo_dir="$aur_cache/comtrya"

not-git-repo() {
  echo "error: '$repo_dir' exist, but it's not a git repository."
  exit 1
}

install() {
  cargo install --path "$repo_dir/app" --offline
  exit
}

if [[ -e "$repo_dir" ]]; then
  if [[ -d "$repo_dir" ]]; then
    cd "$repo_dir"
    if git rev-parse --is-inside-work-tree 1> /dev/null; then
      install
    fi
  fi
  not-git-repo
else
  git clone "$repo" "$repo_dir"
  install
fi
