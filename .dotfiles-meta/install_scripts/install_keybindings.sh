#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

# Skip on headless/CI environments where gsettings cannot talk to a user D-Bus
if ! command_exists gsettings || { [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; }; then
  echo "Skipping GNOME keybindings configuration (no user D-Bus/display available)"
  exit 0
fi

# Set input source switching keybinding (Ctrl+Space)
if command_exists gsettings; then
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Control>space']"
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift><Control>space']"
fi

# Set up ulauncher keybinding (Super+Space)
if command_exists ulauncher && command_exists gsettings; then
  ULAUNCHER_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/"
  CURRENT_BINDINGS_RAW=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

  # Strip potential '@as ' type annotation from gsettings output
  CURRENT_BINDINGS="${CURRENT_BINDINGS_RAW#@as }"

  if [[ "$CURRENT_BINDINGS" != *"$ULAUNCHER_PATH"* ]]; then
    if [[ "$CURRENT_BINDINGS" == "[]" ]]; then
      NEW_BINDINGS="['$ULAUNCHER_PATH']"
    else
      NEW_BINDINGS=$(echo "$CURRENT_BINDINGS" | sed "s|\]$|, '$ULAUNCHER_PATH']|")
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_BINDINGS"
  fi

  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$ULAUNCHER_PATH" name 'ulauncher'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$ULAUNCHER_PATH" command 'ulauncher-toggle'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$ULAUNCHER_PATH" binding '<Super>space'
fi