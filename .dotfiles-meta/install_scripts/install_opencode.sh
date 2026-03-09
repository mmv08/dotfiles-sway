#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

echo "Installing opencode..."

install_package_if_missing curl

if command_exists opencode; then
    echo "opencode is already installed"
    exit 0
fi

curl -fsSL https://opencode.ai/install | bash

echo "opencode installation completed"
