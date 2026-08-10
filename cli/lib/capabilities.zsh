# Capability detection for the termlab CLI.
#
# Platform detection (cli/lib/platform.zsh) answers "which OS is this".
# This file answers a narrower, more honest question per feature:
#
#   supported    - implemented for this platform, and the tool/hardware
#                  it needs is present right now
#   unavailable  - implemented for this platform, but the tool/hardware
#                  it needs isn't present on this machine (no battery,
#                  Homebrew not installed, ...)
#   unsupported  - no implementation exists for this platform at all
#
# Never collapse these into one another: "not installed" and "not
# possible on this OS" are different problems with different fixes.

typeset -ga TERMLAB_CAPABILITIES=(
    system_information network_interfaces process_management
    battery notifications lock_screen volume_control
    application_launcher package_manager
)

_termlab_cap_battery() {
    case "$TERMLAB_PLATFORM" in
        macos)
            command -v pmset >/dev/null 2>&1 && pmset -g batt 2>/dev/null | grep -q InternalBattery \
                && echo supported || echo unavailable
            ;;
        linux|wsl)
            find /sys/class/power_supply -maxdepth 1 -iname 'BAT*' 2>/dev/null | grep -q . \
                && echo supported || echo unavailable
            ;;
        *) echo unsupported ;;
    esac
}

_termlab_cap_notifications() {
    case "$TERMLAB_PLATFORM" in
        macos) command -v osascript >/dev/null 2>&1 && echo supported || echo unavailable ;;
        linux|wsl) command -v notify-send >/dev/null 2>&1 && echo supported || echo unavailable ;;
        *) echo unsupported ;;
    esac
}

_termlab_cap_lock_screen() {
    case "$TERMLAB_PLATFORM" in
        macos) command -v pmset >/dev/null 2>&1 && echo supported || echo unavailable ;;
        linux|wsl)
            { command -v loginctl >/dev/null 2>&1 || command -v xdg-screensaver >/dev/null 2>&1; } \
                && echo supported || echo unavailable
            ;;
        *) echo unsupported ;;
    esac
}

_termlab_cap_volume_control() {
    case "$TERMLAB_PLATFORM" in
        macos) command -v osascript >/dev/null 2>&1 && echo supported || echo unavailable ;;
        linux|wsl)
            { command -v pactl >/dev/null 2>&1 || command -v amixer >/dev/null 2>&1; } \
                && echo supported || echo unavailable
            ;;
        *) echo unsupported ;;
    esac
}

_termlab_cap_application_launcher() {
    case "$TERMLAB_PLATFORM" in
        macos) command -v open >/dev/null 2>&1 && echo supported || echo unavailable ;;
        linux|wsl) command -v xdg-open >/dev/null 2>&1 && echo supported || echo unavailable ;;
        *) echo unsupported ;;
    esac
}

_termlab_cap_package_manager() {
    case "$TERMLAB_PLATFORM" in
        macos|linux|wsl)
            for pm in brew apt dnf yum pacman zypper; do
                command -v "$pm" >/dev/null 2>&1 && { echo supported; return; }
            done
            echo unavailable
            ;;
        *) echo unsupported ;;
    esac
}

# system_information/network_interfaces/process_management have a working
# implementation on every currently detected platform (macos/linux/wsl);
# they only degrade to "unsupported" on a platform this project doesn't
# recognize at all.
_termlab_cap_system_information() { [ "$TERMLAB_PLATFORM" = "unknown" ] && echo unsupported || echo supported; }
_termlab_cap_network_interfaces()  { [ "$TERMLAB_PLATFORM" = "unknown" ] && echo unsupported || echo supported; }
_termlab_cap_process_management()  { [ "$TERMLAB_PLATFORM" = "unknown" ] && echo unsupported || echo supported; }

termlab_capability_status() {
    local fn="_termlab_cap_$1"
    if ! typeset -f "$fn" >/dev/null; then
        echo "unsupported"
        return
    fi
    "$fn"
}

termlab_capability_symbol() {
    case "$1" in
        supported)   echo "✓" ;;
        unavailable) echo "!" ;;
        *)           echo "—" ;;
    esac
}

termlab_print_capabilities() {
    echo "Capabilities"
    local cap cap_status symbol
    for cap in "${TERMLAB_CAPABILITIES[@]}"; do
        cap_status="$(termlab_capability_status "$cap")"
        symbol="$(termlab_capability_symbol "$cap_status")"
        printf "  %s %-20s %s\n" "$symbol" "$cap" "$cap_status"
    done
}
