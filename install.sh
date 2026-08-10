#!/usr/bin/env bash
# terminal-lab installer.
#
# Backs up ~/.zshrc before touching it, only ever appends an idempotent,
# clearly-marked block, and never enables the auto-launch-on-new-shell
# behavior unless explicitly asked to (--enable-startup).
#
# Usage:
#   ./install.sh                  install, startup integration OFF
#   ./install.sh --enable-startup install, and launch termlab on new shells
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$HOME/.zshrc"
MARK_BEGIN="# >>> terminal-lab >>>"
MARK_END="# <<< terminal-lab <<<"
ENABLE_STARTUP=0

for arg in "$@"; do
    case "$arg" in
        --enable-startup) ENABLE_STARTUP=1 ;;
        -h|--help)
            echo "Usage: $0 [--enable-startup]"
            exit 0
            ;;
        *) echo "Unknown flag: $arg" >&2; exit 1 ;;
    esac
done

echo "== terminal-lab installer =="

# 1. Detect macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Warning: this project targets macOS. Continuing anyway, but" >&2
    echo "         most commands/*/*.zsh modules assume macOS tools." >&2
fi

# 2. Detect zsh
if ! command -v zsh >/dev/null 2>&1; then
    echo "Error: zsh not found. terminal-lab requires zsh." >&2
    exit 1
fi
echo "zsh found: $(command -v zsh)"

# 3. Detect git
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git not found." >&2
    exit 1
fi
echo "git found: $(command -v git)"

# 4. Detect GitHub CLI (optional)
if command -v gh >/dev/null 2>&1; then
    echo "gh found: $(command -v gh)"
else
    echo "gh not found (optional — only needed for repo creation, not for using the CLI)"
fi

# 5. Detect optional dependencies used by specific commands
for dep in curl dig lsof brew python3 speedtest cmatrix; do
    if command -v "$dep" >/dev/null 2>&1; then
        echo "  [ok]      $dep"
    else
        echo "  [missing] $dep (some commands will report a clear error instead of failing silently)"
    fi
done

# 6. Back up existing .zshrc
if [ -f "$ZSHRC" ]; then
    backup="$ZSHRC.termlab-backup-$(date +%Y%m%d%H%M%S)"
    cp "$ZSHRC" "$backup"
    echo "Backed up $ZSHRC -> $backup"
else
    echo "No existing $ZSHRC — a new one will be created."
    touch "$ZSHRC"
fi

# 7. Install: write config from example if missing
if [ ! -f "$REPO_DIR/config" ]; then
    cp "$REPO_DIR/config.example" "$REPO_DIR/config"
    echo "Created $REPO_DIR/config from config.example (edit it freely, it's gitignored)"
fi

# 8. Toggle startup integration in the local config
if [ "$ENABLE_STARTUP" = "1" ]; then
    sed -i.bak 's/^TERMLAB_STARTUP_ENABLED=.*/TERMLAB_STARTUP_ENABLED=1/' "$REPO_DIR/config"
    rm -f "$REPO_DIR/config.bak"
    echo "Startup integration: ENABLED (termlab will launch on new interactive shells)"
else
    echo "Startup integration: disabled (run with --enable-startup to turn it on)"
fi

# 9. Idempotently add the sourcing block to .zshrc
if grep -qF "$MARK_BEGIN" "$ZSHRC" 2>/dev/null; then
    echo "$ZSHRC already has a terminal-lab block — leaving it as is."
else
    {
        echo ""
        echo "$MARK_BEGIN"
        echo "[ -f \"$REPO_DIR/shell/zsh/init.zsh\" ] && source \"$REPO_DIR/shell/zsh/init.zsh\""
        echo "$MARK_END"
    } >>"$ZSHRC"
    echo "Added terminal-lab integration block to $ZSHRC"
fi

echo
echo "== Done =="
echo "What changed:"
echo "  - $ZSHRC: appended one marked block (your existing config is untouched above it)"
echo "  - $REPO_DIR/config: created if missing"
echo
echo "Try it now:  source \"$ZSHRC\"  &&  termlab"
echo "Undo:        ./uninstall.sh"
