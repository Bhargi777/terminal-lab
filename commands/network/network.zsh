#!/usr/bin/env zsh
# termlab network — networking diagnostics.
# Avoids hardcoding unreliable third-party services beyond a well-known
# public-IP endpoint, and only calls it for the "ip" subcommand.
#
# ifconfig/netstat (net-tools) are legacy on Linux and often missing from
# minimal distros; ip/ss (iproute2) are the modern standard there. macOS
# still ships BSD ifconfig/netstat as the primary tools, so both paths are
# tried in tool-availability order rather than hardcoding one per OS.

set -o pipefail

cmd_overview() {
    echo "Local interfaces:"
    if command -v ip >/dev/null 2>&1; then
        ip -brief addr show 2>/dev/null | awk '$1 !~ /^lo/ {print "  " $1 ": " $3}'
    else
        ifconfig | awk '
            /^[a-z]/ {iface=$1; sub(":", "", iface)}
            /inet / && iface !~ /^lo/ {print "  " iface ": " $2}
        '
    fi
    echo
    echo "Default route:"
    if command -v ip >/dev/null 2>&1; then
        ip route show default 2>/dev/null | awk '{print "  " $3 " via " $5}' | head -2
    else
        netstat -rn 2>/dev/null | awk '/^default/ {print "  " $2 " via " $6}' | head -2
    fi
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
    if command -v ss >/dev/null 2>&1; then
        ss -tulnp 2>/dev/null
    elif command -v lsof >/dev/null 2>&1; then
        lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null
    else
        echo "Neither ss nor lsof found." >&2
        return 1
    fi
}

cmd_http() {
    local url="$1"
    if [ -z "$url" ]; then
        echo "Usage: termlab network http <url>" >&2
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
termlab network [subcommand]
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
