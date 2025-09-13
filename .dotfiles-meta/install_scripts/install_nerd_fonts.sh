#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

FONT_DIR="$HOME/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.zip"

mkdir -p "$FONT_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

install_package_if_missing unzip

curl -fL "$ZIP_URL" -o "$TMP_DIR/Inconsolata.zip"
unzip -o -q "$TMP_DIR/Inconsolata.zip" -d "$FONT_DIR"

if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1
fi

echo "✔ Inconsolata Nerd Font installed to $FONT_DIR"

# Configure GNOME Terminal and system monospace font if possible
if command -v gsettings >/dev/null 2>&1; then
  # Detect installed family name
  FONT_FAMILY="Inconsolata Nerd Font"
  if command -v fc-list >/dev/null 2>&1; then
    if fc-list | grep -iq "Inconsolata Nerd Font Mono"; then
      FONT_FAMILY="Inconsolata Nerd Font Mono"
    elif fc-list | grep -iq "Inconsolata Nerd Font"; then
      FONT_FAMILY="Inconsolata Nerd Font"
    fi
  fi
  FONT_SIZE=${NF_FONT_SIZE:-12}

  # Set global monospace font
  gsettings set org.gnome.desktop.interface monospace-font-name "${FONT_FAMILY} ${FONT_SIZE}" >/dev/null 2>&1 || true

  # Configure Ptyxis (modern GNOME terminal)
  if gsettings list-schemas | grep -q "org.gnome.Ptyxis"; then
    gsettings set org.gnome.Ptyxis use-system-font false >/dev/null 2>&1 || true
    gsettings set org.gnome.Ptyxis font-name "${FONT_FAMILY} ${FONT_SIZE}" >/dev/null 2>&1 || true
    echo "✔ Configured Ptyxis terminal font"
  fi
fi
