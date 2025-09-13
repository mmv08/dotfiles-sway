#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

if command_exists slack; then
  exit 0
fi

# Get latest version and download URL from Slack's official API
API_RESPONSE=$(curl -fsSL "https://slack.com/api/desktop.latestRelease?variant=rpm&arch=x64")
LATEST_URL=$(echo "$API_RESPONSE" | sed -n 's/.*"download_url":"\([^"]*\)".*/\1/p' | sed 's/\\//g')

if [ -z "$LATEST_URL" ]; then
  echo "Failed to get download URL from Slack API"
  exit 1
fi

curl -fsSL "$LATEST_URL" -o /tmp/slack.rpm
sudo dnf install -y /tmp/slack.rpm
rm -f /tmp/slack.rpm
