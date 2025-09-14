#!/usr/bin/env bash
set -euo pipefail

# Install useful npm packages globally
# Includes development tools and CLI utilities

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

# Ensure npm is available in non-interactive shells by loading nvm if present
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
echo "DEBUG: NVM_DIR is: $NVM_DIR"
echo "DEBUG: Checking for nvm.sh at: $NVM_DIR/nvm.sh"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "DEBUG: Found nvm.sh, sourcing it..."
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    echo "DEBUG: nvm sourced, checking for Node versions..."
    nvm list || echo "DEBUG: nvm list failed"
    # Ensure we are using an installed Node version
    # Try to use LTS version, install if not present
    if ! nvm use --lts >/dev/null 2>&1; then
        echo "Node.js LTS not found, installing..."
        nvm install --lts >/dev/null 2>&1
        nvm use --lts >/dev/null 2>&1
    fi
    echo "DEBUG: Current node version: $(node --version 2>&1 || echo 'node not found')"
    echo "DEBUG: Current npm version: $(npm --version 2>&1 || echo 'npm not found')"
else
    echo "DEBUG: nvm.sh not found at $NVM_DIR/nvm.sh"
fi

echo "DEBUG: PATH is: $PATH"
echo "DEBUG: which node: $(which node 2>&1 || echo 'not found')"
echo "DEBUG: which npm: $(which npm 2>&1 || echo 'not found')"

echo "Installing global npm packages..."

# Check if npm is available
if ! command_exists npm; then
    echo "ERROR: npm is not installed or not in PATH. Please install Node.js first."
    echo "DEBUG: command -v npm returned: $(command -v npm 2>&1 || echo 'empty')"
    exit 1
fi

# List of npm packages to install globally
packages=(
    "@anthropic-ai/claude-code"
    "@openai/codex"
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    echo "DEBUG: Running npm list -g $package"
    if npm list -g "$package" &> /dev/null; then
        echo "$package is already installed"
    else
        echo "DEBUG: Package not found globally, attempting install..."
        echo "DEBUG: Running npm install -g $package"
        if npm install -g "$package"; then
            echo "$package installed successfully"
        else
            echo "ERROR: Failed to install $package"
            echo "DEBUG: npm install exit code: $?"
            npm install -g "$package" 2>&1 || true  # Run again to see the actual error
        fi
    fi
done

echo "npm packages installation completed"