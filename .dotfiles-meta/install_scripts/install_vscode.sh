#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

REPO_CONTENT='[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc'

setup_rpm_repo "/etc/yum.repos.d/vscode.repo" "$REPO_CONTENT" "https://packages.microsoft.com/keys/microsoft.asc"
if ! command_exists code; then
  sudo dnf check-update || true
  sudo dnf install -y code
fi
