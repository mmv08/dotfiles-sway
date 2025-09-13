#!/usr/bin/env bash
set -euo pipefail

# where Oh My Zsh custom plugins live (default if unset)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# target plugin directory
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# 1) Clone the plugin if it's not already there
if [[ ! -d "$PLUGIN_DIR" ]]; then
  echo "Cloning zsh-autosuggestions into $PLUGIN_DIR..."
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGIN_DIR"
  git clone https://github.com/fdellwing/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat
else
  echo "Updating zsh-autosuggestions in $PLUGIN_DIR..."
  git -C "$PLUGIN_DIR" pull --ff-only
fi

echo "Done! zsh-autosuggestions plugin is up to date."
