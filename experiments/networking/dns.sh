#!/usr/bin/env bash
# Experiment: comparing DNS record types for a hostname.
set -euo pipefail

host="${1:-example.com}"

if ! command -v dig >/dev/null 2>&1; then
    echo "dig not found" >&2
    exit 1
fi

for type in A AAAA MX TXT NS; do
    echo "--- $type ---"
    dig +short "$host" "$type"
    echo
done
