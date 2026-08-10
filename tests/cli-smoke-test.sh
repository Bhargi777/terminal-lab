#!/usr/bin/env bash
# Smoke test: exercise cli/bhargi's non-interactive paths (help, and each
# module's default subcommand) to catch broken dispatch or a module
# script that errors just from being invoked. Not a full test suite —
# a fast "did I break the wiring" check.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BHARGI="$REPO_DIR/cli/bhargi"
fail=0

run() {
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then
        echo "  ok    $desc"
    else
        echo "  FAIL  $desc (exit $?)"
        fail=1
    fi
}

echo "== bhargi CLI smoke test =="
run "bhargi --help"          "$BHARGI" --help
run "bhargi unknown-module"  bash -c "! $BHARGI not-a-real-module"

for mod in system network filesystem processes git python homebrew macos utilities; do
    run "bhargi $mod" "$BHARGI" "$mod"
done

exit $fail
