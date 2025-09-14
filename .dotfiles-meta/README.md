# ⚙️ My Dotfiles

Lightweight dotfiles setup for Fedora using a bare Git repository that tracks files in-place inside `$HOME`.

## 🚀 Quick Start

One command to set up everything:

```bash
curl -fsSL https://raw.githubusercontent.com/mmv08/dotfiles/master/bootstrap.sh | bash
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
| `~/.dotfiles-meta/install.sh` | Main bootstrap script |
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
- **Tools**: VS Code, JetBrains Toolbox, 1Password, Podman
- **Desktop**: GNOME extensions (Dash to Dock, AppIndicator)
- **Fonts**: Nerd Fonts for terminal icons

## 🔧 Customization

Individual scripts in `install_scripts/` can be run independently. All scripts are idempotent and safe to re-run.