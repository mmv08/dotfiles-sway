#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

# Install starship via package manager instead of curl-to-shell
if ! command_exists starship; then
  install_package_if_missing curl

  # Download and verify starship binary
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64) STARSHIP_ARCH="x86_64" ;;
    aarch64) STARSHIP_ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
  esac

  LATEST_URL="https://api.github.com/repos/starship/starship/releases/latest"
  LATEST_VERSION=$(curl -s "$LATEST_URL" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  TARBALL="starship-${STARSHIP_ARCH}-unknown-linux-musl.tar.gz"
  DOWNLOAD_URL="https://github.com/starship/starship/releases/download/${LATEST_VERSION}/${TARBALL}"

  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT

  curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/$TARBALL"
  tar -xzf "$TEMP_DIR/$TARBALL" -C "$TEMP_DIR"
  sudo install "$TEMP_DIR/starship" /usr/local/bin/starship
fi
# Add starship init to shell RC (idempotent block)
add_block_to_shell_rc "# Starship prompt" "$HOME/.zshrc" <<'EOF'
# Starship prompt
eval "$(starship init zsh)"
EOF

# Disable Oh-My-Zsh theme to avoid conflicts
if [[ -f "$HOME/.zshrc" ]] && grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME=""|' "$HOME/.zshrc"
fi

echo "Starship installation complete"
