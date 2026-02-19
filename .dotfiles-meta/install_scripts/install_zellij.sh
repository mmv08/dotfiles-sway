#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

if [ -f "$HOME/.cargo/env" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
fi

if ! command_exists cargo; then
  echo "cargo not found. Run install_rust.sh first."
  exit 1
fi

if command_exists zellij; then
  echo "zellij already installed"
  exit 0
fi

OPENSSL_NO_VENDOR=1 cargo install --locked zellij
echo "zellij installation complete"
