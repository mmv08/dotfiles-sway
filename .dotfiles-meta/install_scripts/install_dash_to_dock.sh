#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

install_package_if_missing gnome-extensions-app
install_package_if_missing gnome-shell-extension-dash-to-dock

enable_gnome_extension "dash-to-dock@micxgx.gmail.com"

if command_exists gsettings; then
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
fi
