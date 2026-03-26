#!/usr/bin/env bash
set -euo pipefail

warn() {
    echo "Warning: $*" >&2
}

run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

set_gdm_default_session() {
    if ! command -v gdbus >/dev/null 2>&1; then
        warn "gdbus not found; skipping GDM default session configuration."
        return 0
    fi

    local target_user="${SUDO_USER:-${USER:-}}"
    if [ -z "$target_user" ] || [ "$target_user" = "root" ]; then
        warn "Could not determine the login user; skipping GDM default session configuration."
        return 0
    fi

    if ! run_privileged systemctl start accounts-daemon.service >/dev/null 2>&1; then
        warn "Could not start accounts-daemon; skipping GDM default session configuration."
        return 0
    fi

    local user_path
    user_path="$(
        run_privileged gdbus call --system \
            --dest org.freedesktop.Accounts \
            --object-path /org/freedesktop/Accounts \
            --method org.freedesktop.Accounts.FindUserByName "$target_user" 2>/dev/null |
            sed -n "s/^(objectpath '\\([^']*\\)'.*/\\1/p"
    )"

    if [ -z "$user_path" ]; then
        user_path="$(
            run_privileged gdbus call --system \
                --dest org.freedesktop.Accounts \
                --object-path /org/freedesktop/Accounts \
                --method org.freedesktop.Accounts.CacheUser "$target_user" 2>/dev/null |
                sed -n "s/^(objectpath '\\([^']*\\)'.*/\\1/p"
        )"
    fi

    if [ -z "$user_path" ]; then
        warn "Could not find an AccountsService user object for $target_user; skipping GDM default session configuration."
        return 0
    fi

    if ! run_privileged gdbus call --system \
        --dest org.freedesktop.Accounts \
        --object-path "$user_path" \
        --method org.freedesktop.Accounts.User.SetSession sway >/dev/null 2>&1; then
        warn "Could not set the default GDM session to sway for $target_user."
        return 0
    fi

    if ! run_privileged gdbus call --system \
        --dest org.freedesktop.Accounts \
        --object-path "$user_path" \
        --method org.freedesktop.Accounts.User.SetSessionType wayland >/dev/null 2>&1; then
        warn "Could not set the default GDM session type to wayland for $target_user."
        return 0
    fi

    local session_value
    local session_type_value
    session_value="$(
        run_privileged gdbus call --system \
            --dest org.freedesktop.Accounts \
            --object-path "$user_path" \
            --method org.freedesktop.DBus.Properties.Get org.freedesktop.Accounts.User Session 2>/dev/null ||
            true
    )"
    session_type_value="$(
        run_privileged gdbus call --system \
            --dest org.freedesktop.Accounts \
            --object-path "$user_path" \
            --method org.freedesktop.DBus.Properties.Get org.freedesktop.Accounts.User SessionType 2>/dev/null ||
            true
    )"

    if printf '%s' "$session_value" | grep -Fq "<'sway'>" &&
        printf '%s' "$session_type_value" | grep -Fq "<'wayland'>"; then
        echo "GDM will default to the Sway Wayland session for $target_user."
    else
        warn "Could not verify the stored GDM session defaults for $target_user."
    fi
}

if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl not found; skipping display manager configuration."
    exit 0
fi

if ! rpm -q gdm >/dev/null 2>&1; then
    echo "gdm is not installed; skipping display manager configuration."
    exit 0
fi

echo "Enabling GDM as the display manager..."
run_privileged systemctl disable sddm.service --force >/dev/null 2>&1 || true
run_privileged systemctl enable gdm.service --force

active_display_manager="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
if [ "$active_display_manager" = "/usr/lib/systemd/system/gdm.service" ]; then
    echo "GDM is configured as the active display manager."
else
    echo "Warning: display-manager.service does not point to gdm.service" >&2
fi

set_gdm_default_session
