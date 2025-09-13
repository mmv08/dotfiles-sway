# ⚙️ My Dotfiles

Lightweight dotfiles setup for Fedora using a bare Git repository that tracks files in-place inside `$HOME`.

## 🚀 Quick Start

```bash
# Clone bare repo
git clone --bare http://github.com/mmv08/dotfiles $HOME/.dotfiles

# Create helper alias and checkout files
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dot checkout
dot config --local status.showUntrackedFiles no

# Run bootstrap installer
~/.dotfiles-meta/install.sh
```

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