#!/usr/bin/env bash
set -euo pipefail

echo "→ Installing GNOME Extensions app and AppIndicator/KStatusNotifierItem support..."
sudo dnf install -y gnome-extensions-app gnome-shell-extension-appindicator

echo "→ Enabling AppIndicator extension..."
# The extension may not be available until GNOME Shell is restarted or the user logs out and in again.
# The upstream UUID is typically 'appindicatorsupport@rgcjonas.gmail.com'. Check for it before enabling.
if gnome-extensions list | grep -q 'appindicatorsupport@rgcjonas.gmail.com'; then
  gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
else
  echo "⚠ AppIndicator extension not found. You may need to log out and log in again before enabling it."
fi

echo "✔ AppIndicator support has been installed."
echo "   ➤ You can manage it via the GNOME Extensions app."
echo "   ➤ Extension page: https://extensions.gnome.org/extension/615/appindicator-support/"



