#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

install_package_if_missing gnome-extensions-app
install_package_if_missing gnome-shell-extension-appindicator

enable_gnome_extension "appindicatorsupport@rgcjonas.gmail.com"
