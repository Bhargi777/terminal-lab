#!/usr/bin/env bash
# Syntax-checks every shell script in the repo. Uses `zsh -n` for .zsh
# files and `bash -n` for .sh files — no execution, so it's safe to run
# anywhere, including CI. Falls back gracefully if shellcheck isn't
# installed (it's optional, not required).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

fail=0

check() {
    local file="$1" checker="$2"
    if $checker -n "$file" 2>&1; then
        echo "  ok    $file"
    else
        echo "  FAIL  $file"
        fail=1
    fi
}

echo "== zsh syntax (.zsh files, cli/bhargi, commands/*/*.zsh) =="
while IFS= read -r -d '' f; do
    check "$f" zsh
done < <(find . -name '*.zsh' -not -path './.git/*' -print0)
check "cli/bhargi" zsh

echo
echo "== bash syntax (.sh files, install.sh, uninstall.sh) =="
while IFS= read -r -d '' f; do
    check "$f" bash
done < <(find . -name '*.sh' -not -path './.git/*' -print0)
check "install.sh" bash
check "uninstall.sh" bash

echo
if command -v pwsh >/dev/null 2>&1; then
    echo "== PowerShell syntax (.ps1 files, Windows CLI) =="
    if ! pwsh -NoProfile -File "$REPO_DIR/tests/windows-syntax-check.ps1"; then
        fail=1
    fi
else
    echo "pwsh not installed — skipping PowerShell syntax check (see tests/windows-syntax-check.ps1, runs in CI on windows-latest)."
fi

echo
if command -v shellcheck >/dev/null 2>&1; then
    echo "== shellcheck (optional, informational only) =="
    find . \( -name '*.sh' -o -name '*.zsh' \) -not -path './.git/*' -print0 \
        | xargs -0 shellcheck -S warning || true
else
    echo "shellcheck not installed — skipping optional lint pass."
fi

exit $fail
