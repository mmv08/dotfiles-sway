#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

install_package_if_missing curl

export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
  git -C "$NVM_DIR" pull --ff-only
fi

# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm alias default 'lts/*'

