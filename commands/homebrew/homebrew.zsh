#!/usr/bin/env zsh
# termlab homebrew — read-only by default. "upgrade" is the only mutating
# subcommand and always asks for confirmation first.

set -o pipefail

_termlab_require_brew() {
    command -v brew >/dev/null 2>&1 || {
        echo "Homebrew not installed (https://brew.sh)" >&2
        return 1
    }
}

cmd_info() {
    _termlab_require_brew || return 1
    brew --version
    echo "Prefix   : $(brew --prefix)"
    echo "Packages : $(brew list --formula 2>/dev/null | wc -l | tr -d ' ') formulae, $(brew list --cask 2>/dev/null | wc -l | tr -d ' ') casks"
}

cmd_list() {
    _termlab_require_brew || return 1
    brew list --formula
}

cmd_outdated() {
    _termlab_require_brew || return 1
    brew outdated
}

cmd_update() {
    _termlab_require_brew || return 1
    brew update
}

cmd_upgrade() {
    _termlab_require_brew || return 1
    echo "Outdated packages:"
    brew outdated
    printf "Upgrade all of the above? Type 'yes' to confirm: "
    read -r confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        return 1
    fi
    brew upgrade
}

case "${1:-info}" in
    info)     cmd_info ;;
    list)     cmd_list ;;
    outdated) cmd_outdated ;;
    update)   cmd_update ;;
    upgrade)  cmd_upgrade ;;
    -h|--help|help)
        cat <<EOF
termlab homebrew [subcommand]
  info (default)   brew version + package counts
  list             installed formulae
  outdated         outdated packages
  update           refresh Homebrew's package index
  upgrade          upgrade outdated packages, requires typed confirmation
EOF
        ;;
    *) echo "Unknown homebrew subcommand: $1" >&2; exit 1 ;;
esac
