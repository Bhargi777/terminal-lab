# terminal-lab zsh integration.
#
# install.sh appends a single line to ~/.zshrc to source this file:
#   [ -f "$HOME/terminal-lab/shell/zsh/init.zsh" ] && source "$HOME/terminal-lab/shell/zsh/init.zsh"
#
# Everything below is additive: it never edits or removes existing
# .zshrc content.

export BHARGI_HOME="${BHARGI_HOME:-$(cd "$(dirname "${(%):-%N}")/../.." && pwd)}"

source "$BHARGI_HOME/shell/functions/config.zsh"
source "$BHARGI_HOME/shell/aliases/core.zsh"
source "$BHARGI_HOME/shell/functions/dev.zsh"
source "$BHARGI_HOME/shell/functions/macos.zsh"
source "$BHARGI_HOME/shell/prompt/starship.zsh"

export PATH="$BHARGI_HOME/cli:$PATH"

# Optional: launch the bhargi menu on new interactive Terminal sessions.
# Guarded by BHARGI_ACTIVE so choosing "T -> Terminal" inside the menu
# (which execs a fresh shell) never re-triggers the menu recursively.
if [ "$BHARGI_STARTUP_ENABLED" = "1" ] && [ -z "$BHARGI_ACTIVE" ] && [ -o interactive ]; then
    bhargi
fi
