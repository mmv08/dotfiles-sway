#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

# Install GNOME extensions app
install_package_if_missing gnome-extensions-app

# Install dash-to-dock extension
install_package_if_missing gnome-shell-extension-dash-to-dock
enable_gnome_extension "dash-to-dock@micxgx.gmail.com"

# Install appindicator extension
install_package_if_missing gnome-shell-extension-appindicator
enable_gnome_extension "appindicatorsupport@rgcjonas.gmail.com"

# Install Tactile extension (manual installation since not in repos)
if command_exists gnome-extensions && ! gnome-extensions list | grep -q "tactile@lundal.io"; then
  TACTILE_URL="https://extensions.gnome.org/extension-data/tactilelundal.io.v29.shell-extension.zip"
  TACTILE_DIR="$HOME/.local/share/gnome-shell/extensions/tactile@lundal.io"

  mkdir -p "$(dirname "$TACTILE_DIR")"
  curl -fsSL "$TACTILE_URL" -o "/tmp/tactile.zip"
  unzip -q "/tmp/tactile.zip" -d "$TACTILE_DIR"
  rm -f "/tmp/tactile.zip"
fi

enable_gnome_extension "tactile@lundal.io"

# Configure window management settings
if command_exists gsettings; then
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
fi