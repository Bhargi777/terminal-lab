#!/usr/bin/env bash
# terminal-lab uninstaller. Removes only the marked block install.sh
# added to ~/.zshrc; touches nothing else in the file, and never deletes
# the repo or the gitignored local `config` file.
set -euo pipefail

ZSHRC="$HOME/.zshrc"
MARK_BEGIN="# >>> terminal-lab >>>"
MARK_END="# <<< terminal-lab <<<"

if [ ! -f "$ZSHRC" ]; then
    echo "No $ZSHRC found — nothing to do."
    exit 0
fi

if ! grep -qF "$MARK_BEGIN" "$ZSHRC"; then
    echo "No terminal-lab block found in $ZSHRC — nothing to do."
    exit 0
fi

backup="$ZSHRC.bhargi-backup-$(date +%Y%m%d%H%M%S)"
cp "$ZSHRC" "$backup"
echo "Backed up $ZSHRC -> $backup"

awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0 == b { skip=1; next }
    $0 == e { skip=0; next }
    !skip { print }
' "$ZSHRC" > "$ZSHRC.tmp"
mv "$ZSHRC.tmp" "$ZSHRC"

echo "Removed terminal-lab block from $ZSHRC."
echo "The repository itself and its gitignored config file were left in place."
echo "Reload your shell: source \"$ZSHRC\""
