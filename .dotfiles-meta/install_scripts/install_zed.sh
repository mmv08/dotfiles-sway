#!/usr/bin/env bash
set -euo pipefail

# Install Zed editor
# https://zed.dev

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

echo "Installing Zed editor..."

if command_exists zed; then
    echo "Zed is already installed"
    exit 0
fi

echo "Downloading and running Zed installer..."
curl -f https://zed.dev/install.sh | sh

echo "Zed installation completed"