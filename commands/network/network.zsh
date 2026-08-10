#!/usr/bin/env zsh
# bhargi network — networking diagnostics.
# Avoids hardcoding unreliable third-party services beyond a well-known
# public-IP endpoint, and only calls it for the "ip" subcommand.

set -o pipefail

cmd_overview() {
    echo "Local interfaces:"
    ifconfig | awk '
        /^[a-z]/ {iface=$1; sub(":", "", iface)}
        /inet / && iface !~ /^lo/ {print "  " iface ": " $2}
    '
    echo
    echo "Default route:"
    netstat -rn 2>/dev/null | awk '/^default/ {print "  " $2 " via " $6}' | head -2
}

cmd_ping() {
    local host="${1:-1.1.1.1}"
    echo "Pinging $host (Ctrl+C to stop)..."
    ping -c 4 "$host"
}

cmd_dns() {
    local host="${1:-example.com}"
    if ! command -v dig >/dev/null 2>&1; then
        echo "dig not found, falling back to host(1)" >&2
        host "$host"
        return $?
    fi
    dig +short "$host"
}

cmd_ports() {
    echo "Listening TCP/UDP ports (requires sudo for full process detail):"
    lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null
}

cmd_http() {
    local url="$1"
    if [ -z "$url" ]; then
        echo "Usage: bhargi network http <url>" >&2
        return 1
    fi
    curl -sS -D - -o /dev/null -w "\nTime total: %{time_total}s\nHTTP status: %{http_code}\n" "$url"
}

cmd_ip() {
    echo "Public IP (via ifconfig.me):"
    curl -sS --max-time 5 https://ifconfig.me || echo "Could not reach ifconfig.me" >&2
    echo
}

case "${1:-overview}" in
    overview) cmd_overview ;;
    ping)     shift; cmd_ping "$@" ;;
    dns)      shift; cmd_dns "$@" ;;
    ports)    cmd_ports ;;
    http)     shift; cmd_http "$@" ;;
    ip)       cmd_ip ;;
    -h|--help|help)
        cat <<EOF
bhargi network [subcommand]
  overview (default)   local interfaces + default route
  ping [host]          ping a host (default 1.1.1.1)
  dns [host]           resolve a hostname (default example.com)
  ports                list listening TCP ports
  http <url>           inspect HTTP response headers/timing
  ip                    show public IP
EOF
        ;;
    *) echo "Unknown network subcommand: $1" >&2; exit 1 ;;
esac
