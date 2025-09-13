#!/usr/bin/env bash
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-autosuggestions
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ ! -d "$PLUGIN_DIR" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGIN_DIR"
else
  git -C "$PLUGIN_DIR" pull --ff-only
fi

# Install zsh-bat
BAT_PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-bat"
if [[ ! -d "$BAT_PLUGIN_DIR" ]]; then
  git clone https://github.com/fdellwing/zsh-bat.git "$BAT_PLUGIN_DIR"
else
  git -C "$BAT_PLUGIN_DIR" pull --ff-only
fi
