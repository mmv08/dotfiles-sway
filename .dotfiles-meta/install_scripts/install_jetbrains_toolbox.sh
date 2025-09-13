#!/usr/bin/env bash
# install_jetbrains_toolbox.sh — Install JetBrains Toolbox App on Fedora

set -euo pipefail

echo "→ Installing required packages..."
sudo dnf install -y fuse fuse-libs jq curl

echo "→ Fetching latest JetBrains Toolbox release URL..."
TOOLBOX_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
  | jq -r '.TBA[0].downloads.linux.link')

echo "→ Downloading Toolbox App from $TOOLBOX_URL..."
curl -L "$TOOLBOX_URL" -o /tmp/jetbrains-toolbox.tar.gz

echo "→ Extracting Toolbox App..."
TOOLBOX_DIR="$HOME/.local/share/JetBrains/Toolbox"
mkdir -p "$TOOLBOX_DIR"
tar -xzf /tmp/jetbrains-toolbox.tar.gz -C "$TOOLBOX_DIR" --strip-components=1

echo "→ Locating Toolbox binary..."
JETBRAINS_TOOLBOX_BIN=""
if [ -x "$TOOLBOX_DIR/jetbrains-toolbox" ]; then
  JETBRAINS_TOOLBOX_BIN="$TOOLBOX_DIR/jetbrains-toolbox"
elif [ -x "$TOOLBOX_DIR/bin/jetbrains-toolbox" ]; then
  JETBRAINS_TOOLBOX_BIN="$TOOLBOX_DIR/bin/jetbrains-toolbox"
else
  # Fallback: search within a few levels just in case structure changes
  JETBRAINS_TOOLBOX_BIN=$(find "$TOOLBOX_DIR" -maxdepth 3 -type f -name jetbrains-toolbox -perm -u+x -print -quit || true)
fi

if [ -z "${JETBRAINS_TOOLBOX_BIN:-}" ]; then
  echo "✖ Could not locate the jetbrains-toolbox binary under $TOOLBOX_DIR"
  exit 1
fi

echo "→ Creating symbolic link..."
LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"
ln -sf "$JETBRAINS_TOOLBOX_BIN" "$LOCAL_BIN_DIR/jetbrains-toolbox"

echo "→ Creating desktop entry..."
mkdir -p ~/.local/share/applications
DESKTOP_FILE="$HOME/.local/share/applications/jetbrains-toolbox.desktop"
ICON_PATH="$TOOLBOX_DIR/toolbox.svg"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=JetBrains Toolbox
Comment=Manage your JetBrains tools
Exec=$LOCAL_BIN_DIR/jetbrains-toolbox
TryExec=$LOCAL_BIN_DIR/jetbrains-toolbox
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

if command -v update-desktop-database >/dev/null 2>&1; then
  echo "→ Updating desktop database..."
  update-desktop-database "$HOME/.local/share/applications" || true
fi

echo "✔ JetBrains Toolbox installed successfully."
echo "➡️ Run it with: jetbrains-toolbox"

