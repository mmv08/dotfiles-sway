#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export DOTFILES_ZSH_PLUGINS_ONLY=1
"$SCRIPT_DIR/install_zsh.sh"
