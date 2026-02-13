#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

APP_LIST_FILE="${FLATPAK_APPS_FILE:-$SCRIPT_DIR/flatpak-apps.txt}"

install_flatpak_app_entry() {
  local entry="$1"
  local app_id
  local remote

  # Support appId|remote format for non-default Flatpak remotes.
  if [[ "$entry" == *"|"* ]]; then
    app_id="${entry%%|*}"
    remote="${entry#*|}"
    install_flatpak_app "$app_id" "$remote"
  else
    install_flatpak_app "$entry"
  fi
}

install_apps_from_args() {
  for app in "$@"; do
    install_flatpak_app_entry "$app"
  done
}

install_apps_from_file() {
  local list_file="$1"
  local entry
  local cleaned

  if [ ! -f "$list_file" ]; then
    echo "Flatpak app list not found: $list_file" >&2
    exit 1
  fi

  while IFS= read -r entry || [ -n "$entry" ]; do
    cleaned="$(echo "$entry" | sed -e 's/#.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -z "$cleaned" ] && continue
    install_flatpak_app_entry "$cleaned"
  done < "$list_file"
}

if [ "$#" -gt 0 ]; then
  install_apps_from_args "$@"
else
  install_apps_from_file "$APP_LIST_FILE"
fi
