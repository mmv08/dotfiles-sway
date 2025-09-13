#!/usr/bin/env bash
set -euo pipefail

echo "Updating system packages..."
sudo dnf upgrade --refresh -y

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPTS_DIR="$SCRIPT_DIR/install_scripts"

echo "Starting bootstrap installation..."

# Define execution order: ensure zsh and nerd fonts before starship
priority=(
  "install_zsh.sh"
  "install_nerd_fonts.sh"
  "install_zsh_plugins.sh"
  "install_starship.sh"
  "install_dnf.sh"
  "install_vscode.sh"
)

# Build ordered list of scripts to run
declare -a to_run
for name in "${priority[@]}"; do
  if [ -f "$SCRIPTS_DIR/$name" ]; then
    to_run+=("$SCRIPTS_DIR/$name")
  fi
done
for script in "$SCRIPTS_DIR"/*.sh; do
  skip=false
  for name in "${priority[@]}"; do
    [[ "$script" == "$SCRIPTS_DIR/$name" ]] && { skip=true; break; }
  done
  $skip || to_run+=("$script")
done

# Execute scripts in order
for script in "${to_run[@]}"; do
  script_name="$(basename "$script")"
  echo "Running $script_name..."
  if [ -x "$script" ]; then
    "$script"
  else
    bash "$script"
  fi
done

echo "Bootstrap installation completed."