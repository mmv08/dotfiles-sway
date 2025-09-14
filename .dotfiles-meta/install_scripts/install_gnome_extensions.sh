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
TACTILE_DIR="$HOME/.local/share/gnome-shell/extensions/tactile@lundal.io"
if command_exists gnome-extensions && [ ! -d "$TACTILE_DIR" ]; then
  TACTILE_URL="https://extensions.gnome.org/extension-data/tactilelundal.io.v34.shell-extension.zip"

  mkdir -p "$(dirname "$TACTILE_DIR")"
  curl -fsSL "$TACTILE_URL" -o "/tmp/tactile.zip"
  unzip -q "/tmp/tactile.zip" -d "$TACTILE_DIR"
  rm -f "/tmp/tactile.zip"
fi

enable_gnome_extension "tactile@lundal.io"

# Install Astra Monitor extension from GNOME Extensions website
ASTRA_DIR="$HOME/.local/share/gnome-shell/extensions/monitor@astraext.github.io"
if command_exists gnome-extensions && [ ! -d "$ASTRA_DIR" ]; then
  # From: https://extensions.gnome.org/extension/6682/astra-monitor/
  ASTRA_URL="https://extensions.gnome.org/extension-data/monitorastraext.github.io.v26.shell-extension.zip"

  mkdir -p "$(dirname "$ASTRA_DIR")"
  curl -fsSL "$ASTRA_URL" -o "/tmp/astra-monitor.zip"
  unzip -q "/tmp/astra-monitor.zip" -d "$ASTRA_DIR"
  rm -f "/tmp/astra-monitor.zip"
fi

enable_gnome_extension "monitor@astraext.github.io"

# Configure window management settings
if command_exists gsettings; then
  gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
fi