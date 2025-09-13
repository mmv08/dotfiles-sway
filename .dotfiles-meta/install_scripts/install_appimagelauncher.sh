#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

if check_package_installed appimagelauncher; then
  exit 0
fi

# Get latest release info from GitHub API
LATEST_INFO=$(curl -s https://api.github.com/repos/TheAssassin/AppImageLauncher/releases/latest)
DOWNLOAD_URL=$(echo "$LATEST_INFO" | grep -o 'https://.*x86_64\.rpm' | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Could not find AppImageLauncher download URL"
  exit 1
fi

curl -fsSL "$DOWNLOAD_URL" -o /tmp/appimagelauncher.rpm
sudo dnf install -y /tmp/appimagelauncher.rpm
rm -f /tmp/appimagelauncher.rpm
