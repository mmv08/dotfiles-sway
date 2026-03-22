# GNOME-to-Sway Audit Plan

Audit scope: all 34 tracked files in this repo.

Current state: the repo is mostly shell/tooling/bootstrap logic, with GNOME-specific behavior concentrated in the install layer and docs. There is no Sway-native config tracked yet, so the first cleanup pass should remove GNOME-only automation before adding any Sway-specific replacements.

## Recommended order

1. Remove the GNOME-only installers.
2. Stop calling those installers from the main install flow.
3. Drop leftover GNOME helper code and desktop packages that no longer make sense.
4. Rewrite the docs so the repo no longer claims a GNOME setup.
5. After cleanup, decide which Sway-native replacements you actually want.

## Remove

### `.dotfiles-meta/install_scripts/install_gnome_extensions.sh`

Remove this file entirely.

Why:
- Everything here is GNOME Shell-specific.
- Dash to Dock, AppIndicator, Tactile, and Astra Monitor have no role in Sway.
- It also writes to `~/.local/share/gnome-shell/extensions` and tweaks GNOME window-manager settings.

### `.dotfiles-meta/install_scripts/install_keybindings.sh`

Remove this current implementation and replace the behavior later in Sway config if you still want it.

Why:
- It is entirely based on `gsettings` and GNOME Settings Daemon schemas.
- On Sway, keybindings should live in `~/.config/sway/config` or included Sway config files.
- The `ulauncher` binding here is another sign that launcher choice should be revisited for Wayland.

## Revisit

### `.dotfiles-meta/install.sh`

Suggested changes:
- Remove `install_gnome_extensions.sh` from the `priority` list.
- Remove `install_keybindings.sh` from the `priority` list.
- If you later add Sway-specific installers, make them explicitly session-aware instead of always running them.

### `.dotfiles-meta/install_scripts/utils.sh`

Suggested changes:
- Remove `enable_gnome_extension()` after the GNOME extensions installer is deleted.
- Keep the rest of the shared helpers.

### `.dotfiles-meta/install_scripts/dnf-packages.txt`

Suggested changes:
- Remove or intentionally justify `wmctrl`.
- Remove or intentionally justify `ulauncher`.

Why:
- `wmctrl` is X11-oriented and does not fit a native Sway workflow.
- `ulauncher` is only referenced by the GNOME keybinding script in this repo and is not an especially clean Wayland/Sway fit.

### `.dotfiles-meta/install_scripts/install_nerd_fonts.sh`

Suggested changes:
- Keep the font download/install logic.
- Keep using Inconsolata Nerd Font as the default font from this repo.
- Remove the GNOME/Ptyxis-specific `gsettings` block.
- Replace it with Sway-oriented defaults once the related config files exist in the repo.

Recommended Sway follow-up:
- Set the font in your Sway config for bars and any launcher/menu you adopt.
- Set the same font in your terminal config instead of trying to push GNOME desktop defaults.

Likely targets:
- `~/.config/sway/config`
- `~/.config/waybar/config` or style files
- `~/.config/foot/foot.ini`, `~/.config/kitty/kitty.conf`, `~/.config/alacritty/alacritty.toml`, or your actual terminal config

### `README.md`

Suggested changes:
- Remove the GNOME desktop claim from "What's Installed".
- Either describe the repo as Fedora + Sway, or keep the desktop wording generic until Sway config exists in the repo.

### `.dotfiles-meta/README.md`

Suggested changes:
- Apply the same doc changes as `README.md`.
- Keep both READMEs aligned if you continue storing duplicate copies.

### `.github/workflows/bootstrap.yml`

Suggested changes:
- No immediate GNOME cleanup needed.
- Revisit this only if you add Sway/session-dependent installers, so CI stays green in a headless Fedora container.

## Sway follow-up targets

These are not required for the GNOME cleanup, but they are the natural replacements for removed behavior:

- Launcher: choose a Sway/Wayland-native option such as `fuzzel` or `wofi` instead of relying on `ulauncher`.
- Bar/tray/system indicators: use something like `waybar` instead of Dash to Dock/AppIndicator/Astra Monitor.
- Tiling/layout behavior: use native Sway bindings/config instead of the GNOME Tactile extension.
- Keybindings and input switching: move them into Sway config.
- Screen sharing/portals for Flatpak and browsers: make sure your Sway system packages include the right Wayland portal stack.
- Fonts: keep Inconsolata Nerd Font installed, but make Sway and terminal config consume it directly.

## Audited with no GNOME action required

These files do not contain GNOME-specific behavior that needs removal for the current cleanup:

- `.claude/settings.json`
- `.config/1Password/ssh/agent.toml`
- `.config/zed/settings.json`
- `.dotfiles-meta/bootstrap.sh`
- `.dotfiles-meta/install_scripts/flatpak-apps.txt`
- `.dotfiles-meta/install_scripts/install_1password.sh`
- `.dotfiles-meta/install_scripts/install_appimagelauncher.sh`
- `.dotfiles-meta/install_scripts/install_dnf.sh`
- `.dotfiles-meta/install_scripts/install_flatpak_apps.sh`
- `.dotfiles-meta/install_scripts/install_go.sh`
- `.dotfiles-meta/install_scripts/install_jetbrains_toolbox.sh`
- `.dotfiles-meta/install_scripts/install_node.sh`
- `.dotfiles-meta/install_scripts/install_npm_packages.sh`
- `.dotfiles-meta/install_scripts/install_opencode.sh`
- `.dotfiles-meta/install_scripts/install_podman.sh`
- `.dotfiles-meta/install_scripts/install_rust.sh`
- `.dotfiles-meta/install_scripts/install_starship.sh`
- `.dotfiles-meta/install_scripts/install_vscode.sh`
- `.dotfiles-meta/install_scripts/install_zed.sh`
- `.dotfiles-meta/install_scripts/install_zellij.sh`
- `.dotfiles-meta/install_scripts/install_zsh.sh`
- `.dotfiles-meta/install_scripts/install_zsh_plugins.sh`
- `.gitconfig`
- `.ssh/config`
- `.zshrc`

## Bottom line

The real GNOME cleanup is small and well-contained:

- Delete the GNOME extensions installer.
- Delete the GNOME keybindings installer.
- Remove GNOME references from the main install flow, docs, and helper code.
- Revisit `ulauncher` and `wmctrl`, and convert the font setup from GNOME/Ptyxis settings to Sway-native config.

After that, the repo will stop pretending to be a GNOME setup, but it still will not be a full Sway-configured dotfiles repo until you add Sway-specific config separately.
