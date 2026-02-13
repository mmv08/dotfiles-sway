#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging setup
LOG_FILE="$HOME/.dotfiles-install.log"
echo "Starting dotfiles installation at $(date)" > "$LOG_FILE"

# Helper functions
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] ✓${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ✗${NC} $1" | tee -a "$LOG_FILE"
}

# Cleanup on exit
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Installation interrupted or failed"
    fi
    log "Installation log saved to: $LOG_FILE"
}
trap cleanup EXIT INT

# Check if bare repo exists
if [ ! -d "$HOME/.dotfiles" ]; then
    log_error "Dotfiles repository not found. Run bootstrap.sh first:"
    echo "  curl -fsSL https://raw.githubusercontent.com/mmv08/dotfiles/master/bootstrap.sh | bash"
    exit 1
fi

log "Updating system packages..."
sudo dnf upgrade --refresh -y 2>&1 | tee -a "$LOG_FILE"

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPTS_DIR="$SCRIPT_DIR/install_scripts"

log "Starting bootstrap installation..."

# Define execution order: ensure dependencies run first
priority=(
  "install_zsh.sh"
  "install_nerd_fonts.sh"
  "install_starship.sh"
  "install_flatpak_apps.sh"
  "install_dnf.sh"
  "install_node.sh"
  "install_rust.sh"
  "install_go.sh"
  "install_npm_packages.sh"
  "install_gnome_extensions.sh"
  "install_keybindings.sh"
  "install_vscode.sh"
)

# Build ordered list of scripts to run (excluding utils.sh)
declare -a to_run
declare -a failed_scripts=()
declare -a success_scripts=()

# Add priority scripts first
for name in "${priority[@]}"; do
  if [ -f "$SCRIPTS_DIR/$name" ]; then
    to_run+=("$SCRIPTS_DIR/$name")
  fi
done

# Add remaining scripts (excluding utils.sh)
for script in "$SCRIPTS_DIR"/*.sh; do
  script_name="$(basename "$script")"
  [[ "$script_name" == "utils.sh" ]] && continue

  skip=false
  for name in "${priority[@]}"; do
    [[ "$script" == "$SCRIPTS_DIR/$name" ]] && { skip=true; break; }
  done
  $skip || to_run+=("$script")
done

# Execute scripts in order
total_scripts=${#to_run[@]}
current_script=0

log "Found $total_scripts scripts to execute"

for script in "${to_run[@]}"; do
  current_script=$((current_script + 1))
  script_name="$(basename "$script")"

  log "[$current_script/$total_scripts] Running $script_name..."

  start_time=$(date +%s)

  if [ -x "$script" ]; then
    "$script" >> "$LOG_FILE" 2>&1
  else
    bash "$script" >> "$LOG_FILE" 2>&1
  fi
  exit_code=$?

  end_time=$(date +%s)
  duration=$((end_time - start_time))

  if [ $exit_code -eq 0 ]; then
    log_success "$script_name completed in ${duration}s"
    success_scripts+=("$script_name")
  else
    log_error "$script_name failed (exit code: $exit_code) after ${duration}s"
    failed_scripts+=("$script_name")
  fi
done

# Installation summary
echo
log "Installation Summary:"
log_success "Successfully installed: ${#success_scripts[@]} scripts"
if [ ${#success_scripts[@]} -gt 0 ]; then
  for script in "${success_scripts[@]}"; do
    echo -e "  ${GREEN}✓${NC} $script"
  done
fi

if [ "${#failed_scripts[@]}" -gt 0 ]; then
  log_error "Failed: ${#failed_scripts[@]} scripts"
  for script in "${failed_scripts[@]}"; do
    echo -e "  ${RED}✗${NC} $script"
  done
  echo
  log_error "Check the log file for details: $LOG_FILE"
  exit 1
else
  log_success "All scripts completed successfully!"
fi
