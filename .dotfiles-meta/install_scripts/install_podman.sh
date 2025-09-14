#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

install_package_if_missing podman
install_package_if_missing podman-compose
install_package_if_missing buildah
install_package_if_missing skopeo

# Enable Podman socket for Docker-compatible clients if systemd user session is available
if systemctl --user --version >/dev/null 2>&1 && [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  systemctl --user enable podman.socket || true
  # Only use --now if we can actually start services
  if systemctl --user is-system-running >/dev/null 2>&1 || systemctl --user status >/dev/null 2>&1; then
    systemctl --user start podman.socket || true
  fi
fi






