#!/usr/bin/env zsh
# bhargi macos — macOS automation via native tools (open, osascript, pmset).

set -o pipefail

_bhargi_require_osascript() {
    command -v osascript >/dev/null 2>&1 || { echo "osascript not found" >&2; return 1; }
}

cmd_lock() {
    pmset displaysleepnow
}

cmd_volume() {
    local level="$1"
    _bhargi_require_osascript || return 1
    if [ -z "$level" ]; then
        osascript -e "output volume of (get volume settings)"
        return 0
    fi
    osascript -e "set volume output volume $level"
}

cmd_mute() {
    _bhargi_require_osascript || return 1
    osascript -e 'set volume with output muted'
}

cmd_unmute() {
    _bhargi_require_osascript || return 1
    osascript -e 'set volume without output muted'
}

cmd_open() {
    local target="$1"
    if [ -z "$target" ]; then
        echo "Usage: bhargi macos open <app-name-or-url>" >&2
        return 1
    fi
    case "$target" in
        http://*|https://*) open "$target" ;;
        *) open -a "$target" 2>/dev/null || open "$target" ;;
    esac
}

cmd_notify() {
    local message="$1"
    local title="${2:-bhargi}"
    _bhargi_require_osascript || return 1
    if [ -z "$message" ]; then
        echo "Usage: bhargi macos notify <message> [title]" >&2
        return 1
    fi
    osascript -e "display notification \"$message\" with title \"$title\""
}

cmd_say() {
    if [ -z "$1" ]; then
        echo "Usage: bhargi macos say <text>" >&2
        return 1
    fi
    say "$@"
}

cmd_settings() {
    open -a "System Settings"
}

case "${1:-}" in
    lock)     cmd_lock ;;
    volume)   shift; cmd_volume "$@" ;;
    mute)     cmd_mute ;;
    unmute)   cmd_unmute ;;
    open)     shift; cmd_open "$@" ;;
    notify)   shift; cmd_notify "$@" ;;
    say)      shift; cmd_say "$@" ;;
    settings) cmd_settings ;;
    -h|--help|help|"")
        cat <<EOF
bhargi macos <subcommand>
  lock              sleep the display
  volume [0-100]    get or set output volume
  mute / unmute     mute/unmute output audio
  open <app|url>    open an application or URL
  notify <msg> [title]  show a macOS notification
  say <text>        text-to-speech
  settings          open System Settings
EOF
        ;;
    *) echo "Unknown macos subcommand: $1" >&2; exit 1 ;;
esac
