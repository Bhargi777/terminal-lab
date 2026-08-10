#!/usr/bin/env bash
# Smoke test: exercise cli/bhargi's non-interactive paths (help, and each
# module's --help) to catch broken dispatch or a module script with a
# syntax/runtime error just from being invoked. Not a full test suite —
# a fast "did I break the wiring" check.
#
# Modules are hit with --help rather than their bare default action:
# several defaults (homebrew info, system battery-adjacent paths) touch
# tools that may not exist on a given machine or CI runner (no Homebrew
# on Linux, no battery on a desktop) — that's an environment gap, not a
# dispatch bug, and --help never depends on external tools being present.
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
run "bhargi platform"        "$BHARGI" platform
run "bhargi unknown-module"  bash -c "! $BHARGI not-a-real-module"

for mod in system network filesystem processes git python homebrew macos linux packages utilities; do
    run "bhargi $mod --help" "$BHARGI" "$mod" --help
done

exit $fail
