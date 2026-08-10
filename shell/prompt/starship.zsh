# Prompt integration. Falls back gracefully if starship isn't installed —
# the original .zshrc would just print a "command not found" every prompt.

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
