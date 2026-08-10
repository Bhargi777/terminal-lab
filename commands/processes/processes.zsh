#!/usr/bin/env zsh
# bhargi processes — process inspection. Anything that can terminate a
# process requires an explicit typed confirmation; nothing here kills
# silently.

set -o pipefail

cmd_top() {
    local n="${1:-10}"
    echo "Top $n processes by CPU:"
    # head closes the pipe early, which sends ps a SIGPIPE (exit 141);
    # that's expected truncation, not a real failure, so pipefail is
    # suspended just for this pipeline.
    ( set +o pipefail; ps -Ao pid,ppid,pcpu,pmem,comm -r | head -n $((n + 1)) )
}

cmd_mem() {
    local n="${1:-10}"
    echo "Top $n processes by memory:"
    ( set +o pipefail; ps -Ao pid,ppid,pcpu,pmem,comm -m | head -n $((n + 1)) )
}

cmd_ports() {
    echo "Processes with open network connections:"
    ( set +o pipefail; lsof -iTCP -iUDP -n -P 2>/dev/null | head -n 40 )
}

cmd_kill() {
    local pid="$1"
    if [ -z "$pid" ]; then
        echo "Usage: bhargi processes kill <pid> [signal]" >&2
        return 1
    fi
    local sig="${2:-TERM}"

    if ! ps -p "$pid" >/dev/null 2>&1; then
        echo "No process with PID $pid" >&2
        return 1
    fi

    ps -p "$pid" -o pid,ppid,pcpu,pmem,comm
    printf "Send SIG%s to PID %s? Type 'yes' to confirm: " "$sig" "$pid"
    read -r confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        return 1
    fi
    kill -s "$sig" "$pid"
}

case "${1:-top}" in
    top)   shift; cmd_top "$@" ;;
    mem)   shift; cmd_mem "$@" ;;
    ports) cmd_ports ;;
    kill)  shift; cmd_kill "$@" ;;
    -h|--help|help)
        cat <<EOF
bhargi processes [subcommand]
  top [n] (default)   top n processes by CPU (default 10)
  mem [n]             top n processes by memory
  ports               processes with open network connections
  kill <pid> [signal] terminate a process, requires typed confirmation
EOF
        ;;
    *) echo "Unknown processes subcommand: $1" >&2; exit 1 ;;
esac
