# Module registry and dispatch for the termlab CLI.
# Each module is a standalone executable at commands/<name>/<name>.zsh
# that takes its own subcommands and prints help with no arguments.

typeset -ga TERMLAB_MODULES=(system network filesystem processes git python packages homebrew macos linux utilities)

termlab_module_path() {
    echo "$TERMLAB_HOME/commands/$1/$1.zsh"
}

termlab_dispatch() {
    local mod="$1"; shift
    local script
    script="$(termlab_module_path "$mod")"

    if [ ! -x "$script" ]; then
        echo "Unknown module: $mod" >&2
        termlab_print_help
        return 1
    fi

    "$script" "$@"
}

termlab_print_help() {
    cat <<EOF
termlab — personal terminal command center

Usage:
  termlab                launch the interactive menu
  termlab <module> [...] run a module directly
  termlab platform        show detected OS/platform
  termlab T               drop into a normal shell
  termlab --help          show this help

Modules:
EOF
    for m in "${TERMLAB_MODULES[@]}"; do
        printf "  %s\n" "$m"
    done
}

termlab_go_to_terminal() {
    echo "Dropping to shell. Run 'termlab' any time to reopen the menu."
    unset TERMLAB_ACTIVE
    exec "${SHELL:-/bin/zsh}" -l
}
