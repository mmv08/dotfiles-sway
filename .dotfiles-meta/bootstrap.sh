#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/mmv08/dotfiles-sway}"
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_META="$HOME/.dotfiles-meta"
BACKUP_DIR="$DOTFILES_META/backups"

# Helper functions
log() {
    echo -e "${BLUE}[BOOTSTRAP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[BOOTSTRAP] ✓${NC} $1"
}

log_error() {
    echo -e "${RED}[BOOTSTRAP] ✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[BOOTSTRAP] ⚠${NC} $1"
}

# Create backup directory
ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory at $BACKUP_DIR" >&2
    fi
}

# Backup a file if it exists and isn't already backed up
backup_file() {
    local file="$1"
    local backup_name="$(basename "$file").$(date +%Y%m%d_%H%M%S).bak"

    if [ -f "$file" ]; then
        ensure_backup_dir
        cp "$file" "$BACKUP_DIR/$backup_name"
        log "Backed up $file to $BACKUP_DIR/$backup_name" >&2
        echo "$BACKUP_DIR/$backup_name"
    fi
}

# Setup bare git repository
setup_bare_repo() {
    if [ -d "$DOTFILES_DIR" ]; then
        log "Dotfiles repository already exists at $DOTFILES_DIR"

        # Pull latest changes if it's a git repo
        if git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" rev-parse --git-dir >/dev/null 2>&1; then
            log "Fetching latest changes..."
            git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" fetch origin master:master --quiet
        else
            log_error "$DOTFILES_DIR exists but is not a git repository"
            exit 1
        fi
    else
        log "Cloning dotfiles repository..."
        git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
        log_success "Repository cloned successfully"
    fi

    # Configure the repository
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
}

# Checkout dotfiles with conflict handling
checkout_dotfiles() {
    log "Checking out dotfiles..."

    # Create a temporary file to store conflicting files
    local conflicts_file
    conflicts_file=$(mktemp /tmp/dotfiles_conflicts.XXXXXX)

    # Try to checkout
    if git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout >"$conflicts_file" 2>&1; then
        log_success "Dotfiles checked out successfully"
        rm -f "$conflicts_file"
        return 0
    fi

    cat "$conflicts_file"

    # Parse conflicts and backup
    log_warning "Found existing files that would be overwritten. Backing them up..."

    grep "^[[:space:]]" "$conflicts_file" | while read -r file; do
        file=$(echo "$file" | xargs)  # Trim whitespace
        if [ -n "$file" ] && [ -f "$HOME/$file" ]; then
            backup_file "$HOME/$file"
            rm -f "$HOME/$file"
        fi
    done

    # Try checkout again after backing up conflicts
    if git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout 2>&1; then
        log_success "Dotfiles checked out successfully after backing up conflicts"
    else
        log_error "Failed to checkout dotfiles even after backup. Check the git status."
        rm -f "$conflicts_file"
        return 1
    fi

    rm -f "$conflicts_file"
}

# Main bootstrap process
main() {
    log "Starting dotfiles bootstrap process..."

    # Setup the bare repository
    setup_bare_repo

    # Checkout dotfiles
    checkout_dotfiles

    # Save the current .zshrc before installation (it will be restored by install_zsh.sh)
    if [ -f "$HOME/.zshrc" ]; then
        export DOTFILES_ZSHRC_BACKUP=$(backup_file "$HOME/.zshrc")
        log "Saved .zshrc location for restoration: $DOTFILES_ZSHRC_BACKUP"
    fi

    # Run the main installation script
    if [ -x "$DOTFILES_META/install.sh" ]; then
        log "Running installation scripts..."
        "$DOTFILES_META/install.sh" || {
            log_error "Installation failed. Check the log at $HOME/.dotfiles-install.log"
            exit 1
        }
        log_success "Installation completed"
    else
        log_error "Installation script not found or not executable at $DOTFILES_META/install.sh"
        exit 1
    fi

    # Setup the dot alias in current shell config if not present
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc_file" ] && ! grep -q "alias dot=" "$rc_file"; then
            echo "" >> "$rc_file"
            echo "# Dotfiles bare repo management" >> "$rc_file"
            echo "alias dot='git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> "$rc_file"
            log "Added 'dot' alias to $rc_file"
        fi
    done

    echo ""
    log_success "🎉 Bootstrap completed successfully!"
    echo ""
    echo "  Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Use 'dot' command to manage your dotfiles:"
    echo "     dot status        - Check status"
    echo "     dot add <file>    - Track a new file"
    echo "     dot commit        - Commit changes"
    echo "     dot push          - Push to GitHub"
    echo ""
    echo "  To update everything later, just run:"
    echo "  ~/.dotfiles-meta/install.sh"
    echo ""
}

# Run main function
main "$@"
