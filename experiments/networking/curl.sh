#!/usr/bin/env bash
# Experiment: curl's timing breakdown for a single HTTP request.
set -euo pipefail

url="${1:-https://example.com}"

curl -sS -o /dev/null "$url" -w '
lookup      : %{time_namelookup}s
connect     : %{time_connect}s
tls handshake: %{time_appconnect}s
first byte  : %{time_starttransfer}s
total       : %{time_total}s
status      : %{http_code}
'
