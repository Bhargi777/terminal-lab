#!/usr/bin/env bash
# Validates cli/lib/platform.zsh's detection against the OS actually
# running the test, and checks the menu/dispatch machinery agrees.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

expected="unknown"
case "$(uname -s)" in
    Darwin) expected="macos" ;;
    Linux)
        if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
            expected="wsl"
        else
            expected="linux"
        fi
        ;;
esac

detected="$(zsh -c "source '$REPO_DIR/cli/lib/platform.zsh'; bhargi_detect_platform")"

echo "== platform detection =="
if [ "$detected" = "$expected" ]; then
    echo "  ok    detected '$detected' matches expected '$expected'"
else
    echo "  FAIL  detected '$detected', expected '$expected'"
    fail=1
fi

echo
echo "== bhargi platform command =="
output="$("$REPO_DIR/cli/bhargi" platform)"
if echo "$output" | grep -q "^Platform :"; then
    echo "  ok    bhargi platform prints a Platform line"
    echo "        $output"
else
    echo "  FAIL  bhargi platform did not print the expected format"
    echo "        got: $output"
    fail=1
fi

echo
echo "== OS-appropriate automation module selected =="
menu_module="$(zsh -c "
    BHARGI_HOME='$REPO_DIR'
    source '$REPO_DIR/cli/lib/platform.zsh'
    source '$REPO_DIR/cli/lib/menu.zsh'
    bhargi_menu_os_module
")"
case "$expected" in
    macos) want=macos ;;
    *)     want=linux ;;
esac
if [ "$menu_module" = "$want" ]; then
    echo "  ok    menu selects '$menu_module' automation module"
else
    echo "  FAIL  menu selected '$menu_module', expected '$want'"
    fail=1
fi

exit $fail
