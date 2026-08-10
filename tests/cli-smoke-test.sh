#!/usr/bin/env bash
# Smoke test: exercise cli/termlab's non-interactive paths (help, and each
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
TERMLAB="$REPO_DIR/cli/termlab"
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

echo "== termlab CLI smoke test =="
run "termlab --help"          "$TERMLAB" --help
run "termlab platform"        "$TERMLAB" platform
run "termlab unknown-module"  bash -c "! $TERMLAB not-a-real-module"

for mod in system network filesystem processes git python homebrew macos linux packages utilities; do
    run "termlab $mod --help" "$TERMLAB" "$mod" --help
done

echo
echo "== deprecated bhargi shim =="
run "bhargi --help still works" "$REPO_DIR/cli/bhargi" --help
if "$REPO_DIR/cli/bhargi" --help 2>&1 >/dev/null | grep -q "deprecated"; then
    echo "  ok    bhargi prints a deprecation warning"
else
    echo "  FAIL  bhargi did not print a deprecation warning"
    fail=1
fi

exit $fail
