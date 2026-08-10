# macOS audio/visual helper functions, refactored from the personal .zshrc.
# Fixed from the original: silent failure if osascript is missing.

_termlab_require_osascript() {
    command -v osascript >/dev/null 2>&1 || {
        echo "osascript not found (macOS only)" >&2
        return 1
    }
}

mute() {
    _termlab_require_osascript || return 1
    osascript -e 'set volume with output muted'
}

unmute() {
    _termlab_require_osascript || return 1
    osascript -e 'set volume without output muted'
}

vol() {
    _termlab_require_osascript || return 1
    if [ -z "$1" ]; then
        echo "Usage: vol <0-100>" >&2
        return 1
    fi
    osascript -e "set volume output volume $1"
}

what() {
    open -a "WhatsApp" 2>/dev/null || echo "WhatsApp not installed" >&2
}

cma() {
    command -v cmatrix >/dev/null 2>&1 || { echo "cmatrix not installed (brew install cmatrix)" >&2; return 1; }
    cmatrix
}

# Applies the neon Terminal.app color scheme to the current tab.
neon() {
    _termlab_require_osascript || return 1
    osascript <<'EOF'
tell application "Terminal"
    tell selected tab of front window
        set background color to {0, 0, 0}
        set normal text color to {58853, 61166, 62451}
        set cursor color to {0, 65535, 65535}
    end tell
end tell
EOF
}
