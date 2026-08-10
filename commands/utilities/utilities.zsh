#!/usr/bin/env zsh
# bhargi utilities — grab-bag of the personal .zshrc features that don't
# fit a domain module: identity banner, network speed test, matrix rain.

set -o pipefail
BHARGI_HOME="${BHARGI_HOME:-$(cd "$(dirname "${0:A}")/../.." && pwd)}"
[ -f "$BHARGI_HOME/shell/functions/config.zsh" ] && source "$BHARGI_HOME/shell/functions/config.zsh"

cmd_whoami() {
    echo "Name     : ${BHARGI_DISPLAY_NAME:-Anonymous}"
    echo "Mac      : $(scutil --get ComputerName 2>/dev/null)"
    echo "User     : $(whoami)"
    echo "Date     : $(date '+%d %B %Y')"
    echo "Time     : $(date '+%I:%M:%S %p')"
}

cmd_speed() {
    if ! command -v speedtest >/dev/null 2>&1; then
        echo "speedtest CLI not installed (brew install speedtest-cli or ookla/speedtest-cli)" >&2
        return 1
    fi
    speedtest
}

cmd_matrix() {
    command -v cmatrix >/dev/null 2>&1 || { echo "cmatrix not installed (brew install cmatrix)" >&2; return 1; }
    cmatrix
}

case "${1:-whoami}" in
    whoami) cmd_whoami ;;
    speed)  cmd_speed ;;
    matrix) cmd_matrix ;;
    -h|--help|help)
        cat <<EOF
bhargi utilities [subcommand]
  whoami (default)   identity banner from config, no hardcoded personal data
  speed              network speed test
  matrix             cmatrix rain
EOF
        ;;
    *) echo "Unknown utilities subcommand: $1" >&2; exit 1 ;;
esac
