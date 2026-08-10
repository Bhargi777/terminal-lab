#!/usr/bin/env zsh
# bhargi system — macOS system information.
# Uses native macOS tools only (sw_vers, uname, sysctl, pmset, df); makes
# no assumption that Linux-style utilities (e.g. free, lscpu) exist.

set -o pipefail

cmd_info() {
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

cmd_battery() {
    if ! command -v pmset >/dev/null 2>&1; then
        echo "pmset not available (desktop Mac without a battery?)" >&2
        return 1
    fi
    pmset -g batt | tail -n +2
}

cmd_memory() {
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

cmd_disk() {
    df -H / /System/Volumes/Data 2>/dev/null | awk 'NR==1 || NR>1'
}

cmd_uptime() {
    uptime
}

case "${1:-info}" in
    info)    cmd_info ;;
    battery) cmd_battery ;;
    memory)  cmd_memory ;;
    disk)    cmd_disk ;;
    uptime)  cmd_uptime ;;
    -h|--help|help)
        cat <<EOF
bhargi system [subcommand]
  info (default)   macOS version, kernel, model, CPU, memory summary
  battery          battery charge and health via pmset
  memory           memory usage breakdown via vm_stat
  disk             disk usage via df
  uptime           system uptime
EOF
        ;;
    *) echo "Unknown system subcommand: $1" >&2; exit 1 ;;
esac
