#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

install_package_if_missing zsh

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  export KEEP_ZSHRC=yes RUNZSH=no
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
