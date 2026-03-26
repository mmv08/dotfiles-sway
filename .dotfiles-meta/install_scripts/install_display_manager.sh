#!/usr/bin/env bash
set -euo pipefail

if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl not found; skipping display manager configuration."
    exit 0
fi

if ! rpm -q gdm >/dev/null 2>&1; then
    echo "gdm is not installed; skipping display manager configuration."
    exit 0
fi

echo "Enabling GDM as the display manager..."
sudo systemctl disable sddm.service --force >/dev/null 2>&1 || true
sudo systemctl enable gdm.service --force

active_display_manager="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
if [ "$active_display_manager" = "/usr/lib/systemd/system/gdm.service" ]; then
    echo "GDM is configured as the active display manager."
else
    echo "Warning: display-manager.service does not point to gdm.service" >&2
fi
