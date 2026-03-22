#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

FONT_DIR="$HOME/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.zip"
SWAY_CONFIG_DIR="$HOME/.config/sway"
SWAY_CONFIG_FILE="$SWAY_CONFIG_DIR/config"
SWAY_CONFIG_SNIPPETS_DIR="$SWAY_CONFIG_DIR/config.d"
SWAY_FONT_FILE="$SWAY_CONFIG_SNIPPETS_DIR/50-dotfiles-fonts.conf"
SWAY_INCLUDE_LINE='include ~/.config/sway/config.d/*.conf'

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

FONT_FAMILY="Inconsolata Nerd Font"
if command -v fc-list >/dev/null 2>&1; then
  if fc-list | grep -iq "Inconsolata Nerd Font Mono"; then
    FONT_FAMILY="Inconsolata Nerd Font Mono"
  elif fc-list | grep -iq "Inconsolata Nerd Font"; then
    FONT_FAMILY="Inconsolata Nerd Font"
  fi
fi

FONT_SIZE=${NF_FONT_SIZE:-12}

if [ -f /etc/sway/config ] || command -v sway >/dev/null 2>&1 || [ -n "${SWAYSOCK:-}" ]; then
  mkdir -p "$SWAY_CONFIG_SNIPPETS_DIR"

  cat > "$TMP_DIR/50-dotfiles-fonts.conf" <<EOF
# Managed by dotfiles install_nerd_fonts.sh
font pango:${FONT_FAMILY} ${FONT_SIZE}
EOF

  if [ ! -f "$SWAY_FONT_FILE" ] || ! cmp -s "$TMP_DIR/50-dotfiles-fonts.conf" "$SWAY_FONT_FILE"; then
    cp "$TMP_DIR/50-dotfiles-fonts.conf" "$SWAY_FONT_FILE"
    echo "✔ Configured Sway font override at $SWAY_FONT_FILE"
  else
    echo "✔ Sway font override already up to date"
  fi

  if [ -f "$SWAY_CONFIG_FILE" ]; then
    if ! grep -Fqx "$SWAY_INCLUDE_LINE" "$SWAY_CONFIG_FILE"; then
      cat >> "$SWAY_CONFIG_FILE" <<'EOF'

# Load per-user overrides managed by dotfiles.
include ~/.config/sway/config.d/*.conf
EOF
      echo "✔ Added Sway config.d include to $SWAY_CONFIG_FILE"
    fi
  else
    mkdir -p "$SWAY_CONFIG_DIR"
    if [ -f /etc/sway/config ]; then
      cat > "$SWAY_CONFIG_FILE" <<'EOF'
# Load the distro defaults first.
include /etc/sway/config

# Load per-user overrides managed by dotfiles.
include ~/.config/sway/config.d/*.conf
EOF
    else
      cat > "$SWAY_CONFIG_FILE" <<'EOF'
# Load per-user overrides managed by dotfiles.
include ~/.config/sway/config.d/*.conf
EOF
    fi
    echo "✔ Created $SWAY_CONFIG_FILE for Sway font overrides"
  fi
else
  echo "Skipping Sway font configuration (sway not detected)"
fi
