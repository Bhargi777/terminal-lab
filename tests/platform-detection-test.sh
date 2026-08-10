#!/usr/bin/env bash
# Validates cli/lib/platform.zsh's detection against the OS actually
# running the test, checks the menu/dispatch machinery agrees, and
# checks the capability layer returns one of the three defined states
# for every registered capability (never something ad hoc).
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

detected="$(zsh -c "source '$REPO_DIR/cli/lib/platform.zsh'; termlab_detect_platform")"

echo "== platform detection =="
if [ "$detected" = "$expected" ]; then
    echo "  ok    detected '$detected' matches expected '$expected'"
else
    echo "  FAIL  detected '$detected', expected '$expected'"
    fail=1
fi

echo
echo "== termlab platform command =="
output="$("$REPO_DIR/cli/termlab" platform)"
if echo "$output" | grep -q "^Platform$" && echo "$output" | grep -q "^OS "; then
    echo "  ok    termlab platform prints OS/Version/Architecture/Shell/Environment"
else
    echo "  FAIL  termlab platform did not print the expected format"
    echo "        got: $output"
    fail=1
fi

echo
echo "== capability detection =="
cap_output="$(zsh -c "
    TERMLAB_HOME='$REPO_DIR'
    source '$REPO_DIR/cli/lib/platform.zsh'
    source '$REPO_DIR/cli/lib/capabilities.zsh'
    for cap in \"\${TERMLAB_CAPABILITIES[@]}\"; do
        termlab_capability_status \"\$cap\"
    done
")"
bad_states="$(echo "$cap_output" | grep -Ev '^(supported|unavailable|unsupported)$' || true)"
if [ -z "$bad_states" ] && [ "$(echo "$cap_output" | wc -l | tr -d ' ')" = "9" ]; then
    echo "  ok    all 9 capabilities report supported/unavailable/unsupported"
else
    echo "  FAIL  unexpected capability status output:"
    echo "$cap_output" | sed 's/^/        /'
    fail=1
fi

echo
echo "== OS-appropriate automation module selected =="
menu_module="$(zsh -c "
    TERMLAB_HOME='$REPO_DIR'
    source '$REPO_DIR/cli/lib/platform.zsh'
    source '$REPO_DIR/cli/lib/menu.zsh'
    termlab_menu_os_module
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
