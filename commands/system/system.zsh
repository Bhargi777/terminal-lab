#!/usr/bin/env zsh
# bhargi system — system information, branched by platform.
# macOS uses sw_vers/sysctl/pmset; Linux uses /proc and /etc/os-release
# directly so it works even without free/lscpu (procps/util-linux), only
# using those tools as a nicer-formatted option when present.

set -o pipefail

BHARGI_HOME="${BHARGI_HOME:-$(cd "$(dirname "${0:A}")/../.." && pwd)}"
[ -f "$BHARGI_HOME/cli/lib/platform.zsh" ] && source "$BHARGI_HOME/cli/lib/platform.zsh"
BHARGI_PLATFORM="${BHARGI_PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')}"

# ---- macOS ----

mac_info() {
    echo "macOS      : $(sw_vers -productName) $(sw_vers -productVersion) (build $(sw_vers -buildVersion))"
    echo "Kernel     : $(uname -v)"
    echo "Arch       : $(uname -m)"
    echo "Model      : $(sysctl -n hw.model 2>/dev/null)"
    echo "CPU        : $(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
    echo "Cores      : $(sysctl -n hw.ncpu 2>/dev/null)"
    echo "Memory     : $(( $(sysctl -n hw.memsize 2>/dev/null) / 1024 / 1024 / 1024 )) GB"
    echo "Hostname   : $(scutil --get ComputerName 2>/dev/null || hostname)"
    echo "User       : $(whoami)"
    echo "Shell      : $SHELL"
    echo "Uptime     : $(uptime | sed 's/.*up //;s/,.*users.*//')"
}

mac_battery() {
    if ! command -v pmset >/dev/null 2>&1; then
        echo "pmset not available (desktop Mac without a battery?)" >&2
        return 1
    fi
    pmset -g batt | tail -n +2
}

mac_memory() {
    echo "Physical memory : $(( $(sysctl -n hw.memsize 2>/dev/null) / 1024 / 1024 / 1024 )) GB"
    vm_stat | awk '
        /Pages free/ {free=$3}
        /Pages active/ {active=$3}
        /Pages inactive/ {inactive=$3}
        /Pages wired/ {wired=$4}
        END {
            page=4096
            printf "Free            : %.1f GB\n", free*page/1073741824
            printf "Active          : %.1f GB\n", active*page/1073741824
            printf "Inactive        : %.1f GB\n", inactive*page/1073741824
            printf "Wired           : %.1f GB\n", wired*page/1073741824
        }'
}

mac_disk() { df -H / /System/Volumes/Data 2>/dev/null | awk 'NR==1 || NR>1'; }
mac_uptime() { uptime; }

# ---- Linux / WSL ----

linux_distro_name() {
    [ -f /etc/os-release ] && ( . /etc/os-release && echo "${PRETTY_NAME:-$ID}" ) || echo "unknown distro"
}

linux_info() {
    echo "Distro     : $(linux_distro_name)"
    echo "Kernel     : $(uname -r)"
    echo "Arch       : $(uname -m)"
    if [ -r /proc/cpuinfo ]; then
        echo "CPU        : $(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo)"
    fi
    echo "Cores      : $(command -v nproc >/dev/null 2>&1 && nproc || grep -c ^processor /proc/cpuinfo 2>/dev/null)"
    if [ -r /proc/meminfo ]; then
        echo "Memory     : $(awk '/MemTotal/ {printf "%.1f GB", $2/1024/1024}' /proc/meminfo)"
    fi
    echo "Hostname   : $(hostname)"
    echo "User       : $(whoami)"
    echo "Shell      : $SHELL"
    echo "Uptime     : $(uptime -p 2>/dev/null || uptime)"
    [ "$BHARGI_PLATFORM" = "wsl" ] && echo "Note       : running under WSL (${WSL_DISTRO_NAME:-unknown distro})"
}

linux_battery() {
    local bat
    bat=$(find /sys/class/power_supply -maxdepth 1 -iname 'BAT*' 2>/dev/null | head -1)
    if [ -z "$bat" ]; then
        echo "No battery found (desktop or VM?)" >&2
        return 1
    fi
    echo "Capacity : $(cat "$bat/capacity" 2>/dev/null)%"
    echo "Status   : $(cat "$bat/status" 2>/dev/null)"
}

linux_memory() {
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        awk '
            /MemTotal/ {printf "Total     : %.1f GB\n", $2/1024/1024}
            /MemAvailable/ {printf "Available : %.1f GB\n", $2/1024/1024}
        ' /proc/meminfo
    fi
}

linux_disk() { df -h / 2>/dev/null; }
linux_uptime() { uptime -p 2>/dev/null || uptime; }

# ---- dispatch ----

case "$BHARGI_PLATFORM" in
    macos|darwin) info=mac_info; battery=mac_battery; memory=mac_memory; disk=mac_disk; up=mac_uptime ;;
    linux|wsl)    info=linux_info; battery=linux_battery; memory=linux_memory; disk=linux_disk; up=linux_uptime ;;
    *)
        echo "Unsupported platform: $BHARGI_PLATFORM (falling back to Linux-style output)" >&2
        info=linux_info; battery=linux_battery; memory=linux_memory; disk=linux_disk; up=linux_uptime
        ;;
esac

case "${1:-info}" in
    info)    "$info" ;;
    battery) "$battery" ;;
    memory)  "$memory" ;;
    disk)    "$disk" ;;
    uptime)  "$up" ;;
    -h|--help|help)
        cat <<EOF
bhargi system [subcommand]   (platform: $BHARGI_PLATFORM)
  info (default)   OS version, kernel, model, CPU, memory summary
  battery          battery charge and health
  memory           memory usage breakdown
  disk             disk usage
  uptime           system uptime
EOF
        ;;
    *) echo "Unknown system subcommand: $1" >&2; exit 1 ;;
esac
