#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

if command_exists slack; then
  exit 0
fi

# Get latest version dynamically
LATEST_URL=$(curl -sL https://slack.com/ssb/download | grep -o 'https://downloads.slack-edge.com/desktop-releases/linux/x64/[^"]*\.rpm' | head -1)

if [ -z "$LATEST_URL" ]; then
  echo "Could not find Slack download URL"
  exit 1
fi

curl -fsSL "$LATEST_URL" -o /tmp/slack.rpm
sudo dnf install -y /tmp/slack.rpm
rm -f /tmp/slack.rpm
