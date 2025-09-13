#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

PREFIX="/usr/local"
if [[ $# -ge 1 && $1 == "--user" ]]; then
  PREFIX="$HOME/.local"
  mkdir -p "$PREFIX"
  SUDO=""
else
  SUDO="sudo"
fi

LATEST=$(curl -fsSL https://go.dev/VERSION?m=text | head -n1)
[[ -z "$LATEST" ]] && { echo "Couldn't determine latest version"; exit 1; }

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) GOARCH=amd64 ;;
  aarch64) GOARCH=arm64 ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

TARBALL="$LATEST.linux-$GOARCH.tar.gz"
URL="https://go.dev/dl/$TARBALL"
curl -fsSL "$URL" -o "/tmp/$TARBALL"

$SUDO rm -rf "$PREFIX/go"
$SUDO tar -C "$PREFIX" -xzf "/tmp/$TARBALL"

add_to_shell_rc "# Go toolchain
export PATH=\$PATH:$PREFIX/go/bin"

rm -f "/tmp/$TARBALL"
echo "Go $LATEST installed"