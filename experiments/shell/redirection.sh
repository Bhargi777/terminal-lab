#!/usr/bin/env bash
# Experiment: stdout vs stderr redirection, append vs overwrite, and
# combining both streams. Writes only into this script's own temp dir.
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "stdout line" >"$tmp/out.txt"
echo "stderr line" >&2
echo "stderr line" 2>"$tmp/err.txt"

echo "1" >"$tmp/append.txt"
echo "2" >>"$tmp/append.txt"
echo "append.txt contains:"; cat "$tmp/append.txt"

{ echo "stdout"; echo "stderr" >&2; } >"$tmp/both.txt" 2>&1
echo "both.txt (stdout+stderr merged) contains:"; cat "$tmp/both.txt"

echo "here-string demo:"
cat <<< "fed directly from a variable-like string"
