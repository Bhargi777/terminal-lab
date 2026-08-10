#!/usr/bin/env zsh
# bhargi packages — cross-platform package manager detection and safe
# read-only operations. Detects whichever manager is actually installed
# rather than assuming one per OS (a Linux box might have brew too; a Mac
# might not have Homebrew installed at all).
#
# "homebrew" stays a separate, Homebrew-specific module for anyone who
# wants brew's exact subcommands; this module is the generic front door.
# Like homebrew.zsh, "upgrade" is the only mutating subcommand and always
# requires typed confirmation.

set -o pipefail

_bhargi_detect_pm() {
    if command -v brew >/dev/null 2>&1; then echo brew
    elif command -v apt >/dev/null 2>&1; then echo apt
    elif command -v dnf >/dev/null 2>&1; then echo dnf
    elif command -v yum >/dev/null 2>&1; then echo yum
    elif command -v pacman >/dev/null 2>&1; then echo pacman
    elif command -v zypper >/dev/null 2>&1; then echo zypper
    else echo none
    fi
}

PM="$(_bhargi_detect_pm)"

_bhargi_require_pm() {
    if [ "$PM" = "none" ]; then
        echo "No supported package manager found (brew, apt, dnf, yum, pacman, zypper)." >&2
        return 1
    fi
}

cmd_info() {
    _bhargi_require_pm || return 1
    echo "Package manager : $PM"
    case "$PM" in
        brew)   brew --version | head -1 ;;
        apt)    apt --version | head -1 ;;
        dnf)    dnf --version | head -1 ;;
        yum)    yum --version | head -1 ;;
        pacman) pacman --version | head -2 | tail -1 ;;
        zypper) zypper --version ;;
    esac
}

cmd_list() {
    _bhargi_require_pm || return 1
    case "$PM" in
        brew)   brew list --formula ;;
        apt)    apt list --installed 2>/dev/null ;;
        dnf)    dnf list installed ;;
        yum)    yum list installed ;;
        pacman) pacman -Q ;;
        zypper) zypper packages --installed-only ;;
    esac
}

cmd_outdated() {
    _bhargi_require_pm || return 1
    case "$PM" in
        brew)   brew outdated ;;
        apt)    apt list --upgradable 2>/dev/null ;;
        dnf)    dnf check-update || true ;;
        yum)    yum check-update || true ;;
        pacman) pacman -Qu ;;
        zypper) zypper list-updates ;;
    esac
}

cmd_upgrade() {
    _bhargi_require_pm || return 1
    echo "Outdated packages:"
    cmd_outdated
    printf "Upgrade all of the above using %s? Type 'yes' to confirm: " "$PM"
    read -r confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        return 1
    fi
    case "$PM" in
        brew)   brew upgrade ;;
        apt)    sudo apt upgrade ;;
        dnf)    sudo dnf upgrade ;;
        yum)    sudo yum update ;;
        pacman) sudo pacman -Syu ;;
        zypper) sudo zypper update ;;
    esac
}

case "${1:-info}" in
    info)     cmd_info ;;
    list)     cmd_list ;;
    outdated) cmd_outdated ;;
    upgrade)  cmd_upgrade ;;
    -h|--help|help)
        cat <<EOF
bhargi packages [subcommand]   (detected: $PM)
  info (default)   detected package manager + version
  list             installed packages
  outdated         packages with available updates
  upgrade          upgrade outdated packages, requires typed confirmation
EOF
        ;;
    *) echo "Unknown packages subcommand: $1" >&2; exit 1 ;;
esac
