# Module registry and dispatch for the bhargi CLI.
# Each module is a standalone executable at commands/<name>/<name>.zsh
# that takes its own subcommands and prints help with no arguments.

typeset -ga BHARGI_MODULES=(system network filesystem processes git python homebrew macos utilities)

bhargi_module_path() {
    echo "$BHARGI_HOME/commands/$1/$1.zsh"
}

bhargi_dispatch() {
    local mod="$1"; shift
    local script
    script="$(bhargi_module_path "$mod")"

    if [ ! -x "$script" ]; then
        echo "Unknown module: $mod" >&2
        bhargi_print_help
        return 1
    fi

    "$script" "$@"
}

bhargi_print_help() {
    cat <<EOF
bhargi — personal terminal command center

Usage:
  bhargi                launch the interactive menu
  bhargi <module> [...] run a module directly
  bhargi T               drop into a normal shell
  bhargi --help          show this help

Modules:
EOF
    for m in "${BHARGI_MODULES[@]}"; do
        printf "  %s\n" "$m"
    done
}

bhargi_go_to_terminal() {
    echo "Dropping to shell. Run 'bhargi' any time to reopen the menu."
    unset BHARGI_ACTIVE
    exec "${SHELL:-/bin/zsh}" -l
}
