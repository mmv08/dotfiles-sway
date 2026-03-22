#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

FONT_DIR="$HOME/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.zip"

mkdir -p "$FONT_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

font_installed=false
if compgen -G "$FONT_DIR/Inconsolata*Nerd*.ttf" >/dev/null || compgen -G "$FONT_DIR/Inconsolata*Nerd*.otf" >/dev/null; then
  font_installed=true
fi

if [ "$font_installed" = false ]; then
  install_package_if_missing unzip

  curl -fL "$ZIP_URL" -o "$TMP_DIR/Inconsolata.zip"
  unzip -o -q "$TMP_DIR/Inconsolata.zip" -d "$FONT_DIR"

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1
  fi

  echo "✔ Inconsolata Nerd Font installed to $FONT_DIR"
else
  echo "✔ Inconsolata Nerd Font already installed in $FONT_DIR"
fi
