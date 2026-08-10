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

termlab_platform_os_name() {
    case "$TERMLAB_PLATFORM" in
        macos) echo "macOS" ;;
        linux) echo "Linux" ;;
        wsl)   echo "Linux" ;;
        *)     echo "unknown ($(uname -s 2>/dev/null))" ;;
    esac
}

termlab_platform_version() {
    case "$TERMLAB_PLATFORM" in
        macos) sw_vers -productVersion 2>/dev/null ;;
        linux|wsl) termlab_linux_distro ;;
        *) echo "unknown" ;;
    esac
}

termlab_platform_environment() {
    case "$TERMLAB_PLATFORM" in
        wsl) echo "WSL (${WSL_DISTRO_NAME:-unknown distro})" ;;
        *)   echo "Native" ;;
    esac
}

termlab_platform_summary() {
    echo "Platform"
    echo "──────────────────────"
    printf "%-15s %s\n" "OS" "$(termlab_platform_os_name)"
    printf "%-15s %s\n" "Version" "$(termlab_platform_version)"
    printf "%-15s %s\n" "Architecture" "$(uname -m 2>/dev/null)"
    printf "%-15s %s\n" "Shell" "$(basename "${SHELL:-unknown}")"
    printf "%-15s %s\n" "Environment" "$(termlab_platform_environment)"
}

export TERMLAB_PLATFORM="$(termlab_detect_platform)"
