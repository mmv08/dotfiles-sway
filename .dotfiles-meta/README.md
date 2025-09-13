# ⚙️ My Dotfiles

These dotfiles reproduce my day‑to‑day development environment on **Fedora** (and other Linux distros with minor tweaks) without relying on a heavy framework. Everything lives in a single Git **bare** repository that tracks the files **in‑place** inside `$HOME`, plus a handful of bootstrap scripts.

---

## 🧩 Philosophy

- **Simple & transparent** – just Git and a couple of scripts.
- **Track only what matters** – default config is fine unless I've actually changed it.
- **Reproducible** – a one‑liner checks out the dotfiles, another installs the tools.

---

## 📂 Repo layout

| Path                                | Purpose                                                                                                                                                                                    |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `~/.dotfiles`                       | **Bare Git repo** (no working tree)                                                                                                                                                        |
| `~/.dotfiles-meta/`                 | Meta‑files that don't belong directly in `$HOME` – e.g. install scripts, docs, images                                                                                                      |
| `~/.dotfiles-meta/install.sh`       | Main bootstrap script ➜ installs Fedora packages, rustup, nvm, Oh‑My‑Zsh, Starship, Podman, VS Code, etc.                                                                                  |
| `~/.dotfiles-meta/install_scripts/` | Directory of individual installers (e.g. install_1password.sh, install_go.sh, install_node.sh, install_rust.sh, install_vscode.sh, install_zsh.sh, install_starship.sh, install_podman.sh) |
| dot‑tracked files                   | Any real dotfile you see in `$HOME` (`.zshrc`, `.gitconfig`, `~/.config/Code/User/settings.json`, …)                                                                                       |

Add new scripts or docs to `~/.dotfiles-meta`, commit them the same way as any other file.

## 🚀 Bootstrap on a fresh machine

```bash
# 1️⃣  Clone the bare repo into ~/.dotfiles
git clone --bare http://github.com/mmv08/dotfiles $HOME/.dotfiles

# 2️⃣  Create the helper alias and check out tracked files
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dot checkout     # restores .zshrc, .gitconfig, etc.

dot config --local status.showUntrackedFiles no  # hide noisy untracked entries

# (Optional) add the alias permanently to ~/.zshrc

# 3️⃣  Run the main bootstrap script (installs packages & runtimes)
~/.dotfiles-meta/install.sh

# 4️⃣  (If needed) restore your managed .zshrc
# The installers try to preserve .zshrc (KEEP_ZSHRC=yes), but if something
# overwrote it, restore your tracked version and then restart Zsh:
dot checkout ~/.zshrc
exec zsh
```

Open a new shell so PATH changes take effect (Rust, nvm, Go, etc.).

## 🛠️ Daily workflow

| Task              | Command                                         |
| ----------------- | ----------------------------------------------- |
| Track a file      | `dot add ~/.vimrc && dot commit -m "Add vimrc"` |
| Update everything | run `install.sh` again – idempotent             |
| Push changes      | `dot push`                                      |

## ✨ Prompt: Starship

Starship is used for a fast, minimal, cross‑shell prompt. The installer adds the init line to `~/.zshrc`:

```sh
eval "$(starship init zsh)"
```

See the official docs for customization and Nerd Font requirement: [`https://starship.rs/`](https://starship.rs/)

## 🐳 Containers: Podman

Fedora’s default container runtime is Podman. This setup installs `podman`, `podman-compose`, `buildah`, and `skopeo`.

- To use Docker‑compatible clients, enable the user socket and set the host:

```sh
systemctl --user enable --now podman.socket
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
```

## ⚙️ GitHub Actions for Development

By default, GitHub only discovers workflows located in `.github/workflows/` at the repository root. If your workflows are nested inside the meta folder, they won’t be picked up. To enable CI tests on your dotfiles:

1. Move (or copy) the `.github` directory into your repo’s working tree root:

   ```bash
   mv ~/.dotfiles-meta/.github .github
   dot add .github
   dot commit -m "Expose GitHub Actions workflows at repo root"
   dot push
   ```

2. Ensure your workflow YAML files live under `.github/workflows/` in the root of your bare repo checkout.

Now any push or PR to `main` will trigger your bootstrap CI workflow.
