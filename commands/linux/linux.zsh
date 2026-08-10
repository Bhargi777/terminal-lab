#!/usr/bin/env zsh
# bhargi linux — Linux desktop automation, mirroring commands/macos/macos.zsh
# for the subset that has a real Linux equivalent. Tools vary a lot across
# distros/desktop environments, so every action checks for a specific
# binary and reports clearly when it's missing rather than assuming one
# stack (systemd, PulseAudio/PipeWire, a particular notifier) is present.

set -o pipefail

cmd_lock() {
    if command -v loginctl >/dev/null 2>&1; then
        loginctl lock-session
    elif command -v xdg-screensaver >/dev/null 2>&1; then
        xdg-screensaver lock
    else
        echo "No known screen-lock command found (tried loginctl, xdg-screensaver)." >&2
        return 1
    fi
}

cmd_volume() {
    local level="$1"
    if command -v pactl >/dev/null 2>&1; then
        if [ -z "$level" ]; then
            pactl get-sink-volume @DEFAULT_SINK@
        else
            pactl set-sink-volume @DEFAULT_SINK@ "${level}%"
        fi
    elif command -v amixer >/dev/null 2>&1; then
        if [ -z "$level" ]; then
            amixer get Master
        else
            amixer set Master "${level}%"
        fi
    else
        echo "Neither pactl (PulseAudio/PipeWire) nor amixer (ALSA) found." >&2
        return 1
    fi
}

cmd_mute() {
    command -v pactl >/dev/null 2>&1 && { pactl set-sink-mute @DEFAULT_SINK@ 1; return; }
    command -v amixer >/dev/null 2>&1 && { amixer set Master mute; return; }
    echo "Neither pactl nor amixer found." >&2; return 1
}

cmd_unmute() {
    command -v pactl >/dev/null 2>&1 && { pactl set-sink-mute @DEFAULT_SINK@ 0; return; }
    command -v amixer >/dev/null 2>&1 && { amixer set Master unmute; return; }
    echo "Neither pactl nor amixer found." >&2; return 1
}

cmd_open() {
    local target="$1"
    if [ -z "$target" ]; then
        echo "Usage: bhargi linux open <app-or-url>" >&2
        return 1
    fi
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$target"
    else
        echo "xdg-open not found." >&2
        return 1
    fi
}

cmd_notify() {
    local message="$1" title="${2:-bhargi}"
    if [ -z "$message" ]; then
        echo "Usage: bhargi linux notify <message> [title]" >&2
        return 1
    fi
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$message"
    else
        echo "notify-send not found (usually part of libnotify-bin)." >&2
        return 1
    fi
}

cmd_say() {
    if [ -z "$1" ]; then
        echo "Usage: bhargi linux say <text>" >&2
        return 1
    fi
    if command -v spd-say >/dev/null 2>&1; then
        spd-say "$*"
    elif command -v espeak >/dev/null 2>&1; then
        espeak "$*"
    else
        echo "No TTS engine found (tried spd-say, espeak)." >&2
        return 1
    fi
}

case "${1:-}" in
    lock)   cmd_lock ;;
    volume) shift; cmd_volume "$@" ;;
    mute)   cmd_mute ;;
    unmute) cmd_unmute ;;
    open)   shift; cmd_open "$@" ;;
    notify) shift; cmd_notify "$@" ;;
    say)    shift; cmd_say "$@" ;;
    -h|--help|help|"")
        cat <<EOF
bhargi linux <subcommand>
  lock              lock the session (loginctl or xdg-screensaver)
  volume [0-100]    get or set output volume (pactl or amixer)
  mute / unmute     mute/unmute default sink
  open <app|url>    open via xdg-open
  notify <msg> [title]  desktop notification (notify-send)
  say <text>        text-to-speech (spd-say or espeak)
EOF
        ;;
    *) echo "Unknown linux subcommand: $1" >&2; exit 1 ;;
esac
