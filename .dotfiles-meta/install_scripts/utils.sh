#!/usr/bin/env bash

# Common utility functions for installation scripts
# Source this file to access shared functionality

# Check if a package is installed via RPM
check_package_installed() {
  local package_name="$1"
  rpm -q "$package_name" >/dev/null 2>&1
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Setup RPM repository with GPG key verification
setup_rpm_repo() {
  local repo_file="$1"
  local repo_content="$2"
  local gpg_key_url="$3"

  if [ ! -f "$repo_file" ]; then
    sudo rpm --import "$gpg_key_url"
    sudo tee "$repo_file" > /dev/null <<< "$repo_content"
  fi
}

# Install package if not already installed
install_package_if_missing() {
  local package_name="$1"

  if ! check_package_installed "$package_name"; then
    sudo dnf install -y "$package_name"
  fi
}

# Enable GNOME extension
enable_gnome_extension() {
  local extension_uuid="$1"

  if command_exists gnome-extensions; then
    gnome-extensions enable "$extension_uuid" 2>/dev/null || {
      # Fallback for older systems
      dbus-launch --exit-with-session gsettings set org.gnome.shell enabled-extensions \
        "$(gsettings get org.gnome.shell enabled-extensions | sed "s/]/, '$extension_uuid']/")"
    }
  fi
}

# Download file with verification
download_with_verification() {
  local url="$1"
  local output_file="$2"
  local expected_checksum="${3:-}"

  curl -fsSL "$url" -o "$output_file"

  if [ -n "$expected_checksum" ]; then
    local actual_checksum
    actual_checksum=$(sha256sum "$output_file" | cut -d' ' -f1)
    if [ "$actual_checksum" != "$expected_checksum" ]; then
      rm -f "$output_file"
      echo "Checksum verification failed for $output_file" >&2
      return 1
    fi
  fi
}

# Add line to shell RC file if not present
add_to_shell_rc() {
  local line="$1"
  local shell_rc="${2:-$HOME/.zshrc}"

  if [ -f "$shell_rc" ] && ! grep -Fq "$line" "$shell_rc"; then
    echo -e "\n$line" >> "$shell_rc"
  elif [ ! -f "$shell_rc" ]; then
    echo "$line" > "$shell_rc"
  fi
}

# Install flatpak app
install_flatpak_app() {
  local app_id="$1"
  local remote="${2:-flathub}"

  # Ensure flatpak is installed
  install_package_if_missing flatpak

  # Add flathub remote if specified and not present
  if [ "$remote" = "flathub" ] && ! flatpak remote-list | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi

  # Install or update the app
  if flatpak list | grep -q "$app_id"; then
    flatpak update -y "$app_id" 2>/dev/null || true
  else
    flatpak install -y "$remote" "$app_id"
  fi
}