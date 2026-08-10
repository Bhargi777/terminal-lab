# Platform detection for the bhargi CLI (macOS / Linux / WSL / unknown).
# Windows itself is out of scope here — zsh doesn't run natively on
# Windows, so native Windows support lives in cli/windows/ as PowerShell.
# This file only needs to disambiguate the POSIX side.

bhargi_detect_platform() {
    local kernel
    kernel="$(uname -s 2>/dev/null)"

    case "$kernel" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if [ -n "$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

bhargi_linux_distro() {
    if [ -f /etc/os-release ]; then
        ( . /etc/os-release && echo "${PRETTY_NAME:-$ID}" )
    else
        echo "unknown Linux distro"
    fi
}

bhargi_platform_summary() {
    local plat; plat="$(bhargi_detect_platform)"
    case "$plat" in
        macos)
            echo "Platform : macOS $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"
            ;;
        linux)
            echo "Platform : Linux — $(bhargi_linux_distro) ($(uname -m))"
            ;;
        wsl)
            echo "Platform : WSL — $(bhargi_linux_distro) on Windows ($(uname -m))"
            ;;
        *)
            echo "Platform : unrecognized ($kernel) — commands may not work correctly"
            ;;
    esac
}

export BHARGI_PLATFORM="$(bhargi_detect_platform)"
