# Platform detection for the termlab CLI (macOS / Linux / WSL / unknown).
# Windows itself is out of scope here — zsh doesn't run natively on
# Windows, so native Windows support lives in cli/windows/ as PowerShell.
# This file only needs to disambiguate the POSIX side.

termlab_detect_platform() {
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

termlab_linux_distro() {
    if [ -f /etc/os-release ]; then
        ( . /etc/os-release && echo "${PRETTY_NAME:-$ID}" )
    else
        echo "unknown Linux distro"
    fi
}

termlab_platform_summary() {
    local plat; plat="$(termlab_detect_platform)"
    case "$plat" in
        macos)
            echo "Platform : macOS $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"
            ;;
        linux)
            echo "Platform : Linux — $(termlab_linux_distro) ($(uname -m))"
            ;;
        wsl)
            echo "Platform : WSL — $(termlab_linux_distro) on Windows ($(uname -m))"
            ;;
        *)
            echo "Platform : unrecognized ($kernel) — commands may not work correctly"
            ;;
    esac
}

export TERMLAB_PLATFORM="$(termlab_detect_platform)"
