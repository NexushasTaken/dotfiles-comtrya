#!/usr/bin/env bash
set -e

install() {
  local kanata_bin="$HOME/.local/bin/kanata"
  if [[ ! -x $kanata_bin ]]; then
    mkdir -p $(dirname "$kanata_bin")
    wget https://github.com/jtroo/kanata/releases/download/v1.9.0/kanata -O "$kanata_bin"
    chmod +x "$kanata_bin"
  fi

  if ! getent group uinput >/dev/null; then
    sudo groupadd uinput
  fi

  sudo usermod -aG input,uinput "$USER"

  udev_rule="/etc/udev/rules.d/99-uinput.rules"
  if [[ ! -f $udev_rule ]]; then
    echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee "$udev_rule" >/dev/null
  fi

  if [[ -f "$HOME/.config/systemd/user/kanata.service" ]]; then
    systemctl --user enable --now kanata
  fi
}

case $1 in
  install)
    install
    ;;
  *)
    echo "$0 [install]"
    ;;
esac
