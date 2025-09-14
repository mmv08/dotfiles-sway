#!/usr/bin/env bash
set -uo pipefail  # Temporarily remove -e to handle nvm errors gracefully

# Install useful npm packages globally
# Includes development tools and CLI utilities

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

# Ensure npm is available in non-interactive shells by loading nvm if present
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    # Ensure we are using an installed Node version
    # Try default first (which was set during install), then LTS
    if ! nvm use default >/dev/null 2>&1; then
        if ! nvm use --lts >/dev/null 2>&1; then
            echo "Node.js not found, installing LTS..."
            nvm install --lts >/dev/null 2>&1
            nvm use --lts >/dev/null 2>&1
        fi
    fi
fi

echo "Installing global npm packages..."

# Re-enable exit on error after nvm setup
set -e

# Check if npm is available
if ! command_exists npm; then
    echo "npm is not installed. Please install Node.js first."
    exit 1
fi

# List of npm packages to install globally
packages=(
    "@anthropic-ai/claude-code"
    "@openai/codex"
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    if npm list -g "$package" &> /dev/null; then
        echo "$package is already installed"
    else
        if npm install -g "$package"; then
            echo "$package installed successfully"
        else
            echo "Failed to install $package"
        fi
    fi
done

echo "npm packages installation completed"