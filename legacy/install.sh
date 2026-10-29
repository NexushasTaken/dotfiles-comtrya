#!/usr/bin/env bash
set -e

clone() {
  local url="$1"
  local path="$2"
  shift 2

  if [[ ! -d "$path" ]]; then
    mkdir -p $(dirname "$path")
    git clone --depth 1 "$url" "$path" $@
  fi
  echo "$path"
}

to_ansi() {
  printf '\001\e[%sm\002' $1
}

ansi() {
  case "$1" in
    (reset)   to_ansi 0;;
    (black)   to_ansi 30;;
    (red)     to_ansi 31;;
    (green)   to_ansi 32;;
    (yellow)  to_ansi 33;;
    (blue)    to_ansi 34;;
    (magenta) to_ansi 35;;
    (cyan)    to_ansi 36;;
    (white)   to_ansi 37;;
    (orange)  to_ansi 38\;5\;166;;
  esac
}

download() {
  local url="$1"
  local out="$2"
  local dir_out="$(dirname "$out")"
  if [[ ! -d "$dir_out" ]]; then
    mkdir -p "$dir_out"
  fi

  printf "%sDownloading:%s %s\n" "$(ansi green)" "$(ansi reset)" "$out"
  printf "  from: %s\n" "$url"

  while ! wget --passive-ftp -c -O "$out" "$url"; do
    printf "%serror%s: failed to download %s\n" "$(ansi red)" "$(ansi reset)" "$out"
    printf "retrying in %s3%s seconds\n" "$(ansi green)" "$(ansi reset)"
    sleep 3
    if [[ -f "$out" ]]; then
      rm -f "$out"
    fi
  done
}

setup-kanata() {
  local kanata_bin="$HOME/.local/bin/kanata"
  if [[ ! -x "$kanata_bin" ]]; then
    download "https://github.com/jtroo/kanata/releases/download/v1.9.0/kanata" "$kanata_bin"
    chmod +x "$kanata_bin"
  fi

  if ! getent group uinput > /dev/null; then
    sudo groupadd --system uinput
  fi

  sudo usermod -aG input,uinput nexus

  local udev_rule="/etc/udev/rules.d/99-uinput.rules"
  local rule='KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"'
  if [[ ! -f "$udev_rule" ]]; then
    echo "$rule" | sudo tee "$udev_rule"
  fi

  sudo modprobe uinput
}

git-clone() {
  clone https://github.com/Jazqa/adwaita-tweaks.git "$HOME/.themes/Adwaita Tweaks Dark" -b dark
  clone https://github.com/tmux-plugins/tmux-resurrect "$HOME/.config/tmux/plugins/tmux-resurrect"
  clone https://github.com/vinceliuice/Fluent-gtk-theme "$HOME/.local/share/themes/.temp/Fluent-gtk-theme"
  clone https://github.com/cbrnix/Flatery "$HOME/.local/share/icons/.temp/Flatery"
}

install() {
  echo "installing"
  source /etc/os-release
  local tmp=$(mktemp)

  case $ID in
    arch)
      local packages="ttf-hack-nerd git stow tmux dunst alacritty dex rofi wget"
      #local aur_packages="phinger-cursors"
      ## TODO: is there a better way to do this?
      #sudo pacman -Qq $packages > /dev/null 2> $tmp > /dev/null
      #packages=$(awk '/^error:/ { print substr($3, 2, length($3)-2) }' $tmp)
      #echo $packages
      [[ -n $packages ]] && sudo pacman -S $packages --needed
      ;;
    debian|ubuntu) # TODO: not tested
      local packages="git stow tmux" # ttf-hack-nerd ?
      dpkg -s $packages > /dev/null 2> $tmp > /dev/null
      packages=$(awk '/^dpkg-query:/ { print substr($3, 2, length($3)-2) }' $tmp)
      echo $packages
      [[ -n $packages ]] && sudo apt-get install $packages
      ;;
    *);;
  esac

  git-clone

  rm $tmp

  if [[ ! -a '/etc/systemd/system/kanata.service' ]]; then
    sudo cp -vuf ~/.config/kanata/files/kanata.service /etc/systemd/system/kanata.service
    sudo systemctl daemon-reload
  fi

  if [[ -d "$HOME/.local/share/themes/.temp/Fluent-gtk-theme" ]]; then
    pushd ~/.local/share/themes/.temp/Fluent-gtk-theme
      ./install.sh -t all -c dark -s compact -i arch --tweaks square
    popd
  fi

  if [[ -d "$HOME/.local/share/icons/.temp/Flatery" ]]; then
    pushd $HOME/.local/share/icons/.temp/Flatery
      ./install.sh
    popd
  fi
}

stow-now() {
  for dir in systemd/user godot fontconfig; do
    mkdir -p "$HOME/.config/$dir"
  done
  stow . --adopt
}

case $1 in
  install)
    install
    stow-now
    ;;
  stow)
    stow-now
    ;;
  clone)
    git-clone
    ;;
  setup-kanata)
    setup-kanata
    ;;
  *)
    echo "$0 [install|clone]"
    ;;
esac
