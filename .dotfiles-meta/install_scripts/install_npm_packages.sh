#!/usr/bin/env bash
set -euo pipefail

# Install useful npm packages globally
# Includes development tools and CLI utilities

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

echo "Installing global npm packages..."

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