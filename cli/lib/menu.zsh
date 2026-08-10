# Interactive menu for the bhargi CLI.

bhargi_menu_draw() {
    local cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 60)}
    local width=48
    (( cols < width + 2 )) && width=$((cols - 2))

    clear
    print -P "%F{cyan}╭$(printf '─%.0s' {1..46})╮%f"
    print -P "%F{cyan}│%f${BHARGI_COLOR_ACCENT}          BHARGI TERMINAL${BHARGI_COLOR_RESET}$(printf ' %.0s' {1..20})%F{cyan}│%f"
    print -P "%F{cyan}│%f      Personal Command Center$(printf ' %.0s' {1..15})%F{cyan}│%f"
    print -P "%F{cyan}├$(printf '─%.0s' {1..46})┤%f"
    cat <<'EOF'
│                                              │
│  SYSTEM                                     │
│    1  System Information                    │
│    2  Battery                               │
│    3  Filesystem                            │
│    4  Processes                             │
│                                              │
│  DEVELOPMENT                                │
│    5  Git                                   │
│    6  Python                                │
│    7  Homebrew                              │
│                                              │
│  NETWORK                                    │
│    8  Network Diagnostics                   │
│                                              │
│  MACOS                                      │
│    9  macOS Automation                      │
│                                              │
│  T  Terminal      Q  Quit                   │
│                                              │
EOF
    print -P "%F{cyan}╰$(printf '─%.0s' {1..46})╯%f"
    printf "Select: "
}

bhargi_menu_run_choice() {
    local choice="$1"
    case "$choice" in
        1) bhargi_dispatch system ;;
        2) bhargi_dispatch system battery ;;
        3) bhargi_dispatch filesystem ;;
        4) bhargi_dispatch processes ;;
        5) bhargi_dispatch git ;;
        6) bhargi_dispatch python ;;
        7) bhargi_dispatch homebrew ;;
        8) bhargi_dispatch network ;;
        9) bhargi_dispatch macos ;;
        [Tt]) bhargi_go_to_terminal; return $? ;;
        [Qq]) return 99 ;;
        *) echo "Unknown choice: $choice" ;;
    esac
    echo
    echo "Press enter to return to the menu..."
    read -r _
    return 0
}

bhargi_menu() {
    trap 'echo; echo "(Ctrl+C) Use Q to quit or T for a shell."; ' INT

    while true; do
        bhargi_menu_draw
        local choice
        read -r choice
        bhargi_menu_run_choice "$choice"
        local status=$?
        [ "$status" = 99 ] && break
    done

    trap - INT
    echo "Bye."
}
