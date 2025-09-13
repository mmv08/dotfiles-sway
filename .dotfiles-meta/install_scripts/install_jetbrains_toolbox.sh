#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

install_package_if_missing fuse
install_package_if_missing fuse-libs
install_package_if_missing jq
install_package_if_missing curl

TOOLBOX_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
  | jq -r '.TBA[0].downloads.linux.link')

curl -L "$TOOLBOX_URL" -o /tmp/jetbrains-toolbox.tar.gz

TOOLBOX_DIR="$HOME/.local/share/JetBrains/Toolbox"
mkdir -p "$TOOLBOX_DIR"
tar -xzf /tmp/jetbrains-toolbox.tar.gz -C "$TOOLBOX_DIR" --strip-components=1

JETBRAINS_TOOLBOX_BIN=""
if [ -x "$TOOLBOX_DIR/jetbrains-toolbox" ]; then
  JETBRAINS_TOOLBOX_BIN="$TOOLBOX_DIR/jetbrains-toolbox"
elif [ -x "$TOOLBOX_DIR/bin/jetbrains-toolbox" ]; then
  JETBRAINS_TOOLBOX_BIN="$TOOLBOX_DIR/bin/jetbrains-toolbox"
else
  JETBRAINS_TOOLBOX_BIN=$(find "$TOOLBOX_DIR" -maxdepth 3 -type f -name jetbrains-toolbox -perm -u+x -print -quit || true)
fi

if [ -z "${JETBRAINS_TOOLBOX_BIN:-}" ]; then
  echo "Could not locate jetbrains-toolbox binary"
  exit 1
fi

LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"
ln -sf "$JETBRAINS_TOOLBOX_BIN" "$LOCAL_BIN_DIR/jetbrains-toolbox"

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

if command_exists update-desktop-database; then
  update-desktop-database "$HOME/.local/share/applications" || true
fi

