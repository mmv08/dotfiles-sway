#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

REPO_CONTENT='[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc'

setup_rpm_repo "/etc/yum.repos.d/1password.repo" "$REPO_CONTENT" "https://downloads.1password.com/linux/keys/1password.asc"
install_package_if_missing 1password
