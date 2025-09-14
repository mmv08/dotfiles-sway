#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

# Install Synology Drive via Flatpak
install_flatpak_app "com.synology.SynologyDrive"