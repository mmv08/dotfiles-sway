#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

PLUGINS_ONLY="${DOTFILES_ZSH_PLUGINS_ONLY:-0}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

install_plugin() {
  local repo_url="$1"
  local plugin_dir="$2"

  if [ -d "$plugin_dir" ]; then
    git -C "$plugin_dir" pull --ff-only
    return 0
  fi

  git clone "$repo_url" "$plugin_dir"
}

install_zsh_plugins() {
  install_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  install_plugin "https://github.com/fdellwing/zsh-bat.git" \
    "$ZSH_CUSTOM/plugins/zsh-bat"
}

if [ "$PLUGINS_ONLY" = "1" ]; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Run install_zsh.sh first."
    exit 1
  fi

  install_zsh_plugins
  echo "Zsh plugins installation completed"
  exit 0
fi

install_package_if_missing zsh

# Save our custom .zshrc if it exists (either from dotfiles or backup from bootstrap)
ZSHRC_TEMP=""
if [ -f "$HOME/.zshrc" ]; then
  ZSHRC_TEMP=$(mktemp /tmp/zshrc.XXXXXX)
  cp "$HOME/.zshrc" "$ZSHRC_TEMP"
  echo "Saved existing .zshrc to temporary location"
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  export KEEP_ZSHRC=yes RUNZSH=no CHSH=yes
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Oh My Zsh overwrites .zshrc even with KEEP_ZSHRC=yes, so we restore ours
  if [ -n "$ZSHRC_TEMP" ] && [ -f "$ZSHRC_TEMP" ]; then
    echo "Restoring custom .zshrc..."
    cp "$ZSHRC_TEMP" "$HOME/.zshrc"
    echo "Custom .zshrc restored successfully"
  fi
else
  echo "Oh My Zsh already installed"
fi

# Clean up temp file
[ -n "$ZSHRC_TEMP" ] && rm -f "$ZSHRC_TEMP"

# If we have a backup from bootstrap.sh, restore it
if [ -n "${DOTFILES_ZSHRC_BACKUP:-}" ] && [ -f "$DOTFILES_ZSHRC_BACKUP" ]; then
  echo "Restoring .zshrc from bootstrap backup..."
  cp "$DOTFILES_ZSHRC_BACKUP" "$HOME/.zshrc"
  echo "Bootstrap .zshrc restored successfully"
fi

install_zsh_plugins
echo "Zsh plugin installation completed"
