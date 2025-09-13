#!/usr/bin/env bash
# install_podman.sh — Install Podman and basic tooling on Fedora

set -euo pipefail

echo "→ Installing Podman and related tools …"
sudo dnf install -y podman podman-compose buildah skopeo

# Enable Podman socket for Docker-compatible clients (optional)
if systemctl --user --version >/dev/null 2>&1; then
  echo "→ Enabling user podman.socket (Docker-compatible API) …"
  systemctl --user enable --now podman.socket || true
else
  echo "(No systemd --user detected; skipping podman.socket enable)"
fi

echo
echo "✔ Podman installed. Version: $(podman --version)"
echo "   Use 'podman' and 'podman compose'. For Docker CLI compatibility, set DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock"
echo



