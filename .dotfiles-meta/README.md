# ⚙️ My Dotfiles

Lightweight dotfiles setup for Fedora using a bare Git repository that tracks files in-place inside `$HOME`, with shell/tooling bootstrap and Sway-friendly defaults.

## 🚀 Quick Start

One command to set up everything:

```bash
curl -fsSL https://raw.githubusercontent.com/mmv08/dotfiles/master/.dotfiles-meta/bootstrap.sh | bash
```

This will:
- Clone the dotfiles repository
- Backup any conflicting files
- Install all packages and configurations
- Preserve your custom .zshrc through Oh My Zsh installation

## 📂 Structure

| Path | Purpose |
|------|---------|
| `~/.dotfiles` | Bare Git repository |
| `~/.dotfiles-meta/` | Install scripts and meta files |
| `~/.dotfiles-meta/bootstrap.sh` | Bootstrap script for initial setup |
| `~/.dotfiles-meta/install.sh` | Main installation script |
| `~/.dotfiles-meta/install_scripts/` | Individual installers |

## 🛠️ Daily Workflow

```bash
# Track new files
dot add ~/.vimrc && dot commit -m "Add vimrc"

# Update everything
~/.dotfiles-meta/install.sh

# Push changes
dot push
```

## ✨ What's Installed

- **Shell**: Zsh with Oh-My-Zsh, plugins, and Starship prompt
- **Languages**: Node.js (via nvm), Rust, Go
- **Tools**: VS Code, JetBrains Toolbox, 1Password, Podman, Opencode
- **Desktop**: Sway-friendly defaults without desktop-environment-specific extensions
- **Fonts**: Inconsolata Nerd Font for Sway and terminal use

## 🔧 Customization

Individual scripts in `install_scripts/` can be run independently. All scripts are idempotent and safe to re-run.
