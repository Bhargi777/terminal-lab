# terminal-lab zsh integration.
#
# install.sh appends a single line to ~/.zshrc to source this file:
#   [ -f "$HOME/terminal-lab/shell/zsh/init.zsh" ] && source "$HOME/terminal-lab/shell/zsh/init.zsh"
#
# Everything below is additive: it never edits or removes existing
# .zshrc content.

export TERMLAB_HOME="${TERMLAB_HOME:-$(cd "$(dirname "${(%):-%N}")/../.." && pwd)}"

source "$TERMLAB_HOME/shell/functions/config.zsh"
source "$TERMLAB_HOME/shell/aliases/core.zsh"
source "$TERMLAB_HOME/shell/functions/dev.zsh"
source "$TERMLAB_HOME/shell/functions/macos.zsh"
source "$TERMLAB_HOME/shell/prompt/starship.zsh"

export PATH="$TERMLAB_HOME/cli:$PATH"

# Optional: launch the termlab menu on new interactive Terminal sessions.
# Guarded by TERMLAB_ACTIVE so choosing "T -> Terminal" inside the menu
# (which execs a fresh shell) never re-triggers the menu recursively.
if [ "$TERMLAB_STARTUP_ENABLED" = "1" ] && [ -z "$TERMLAB_ACTIVE" ] && [ -o interactive ]; then
    termlab
fi
