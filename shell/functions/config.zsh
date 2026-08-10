# Loads terminal-lab config with safe fallbacks.
# Personal values live in $TERMLAB_HOME/config (gitignored); defaults come
# from config.example so the CLI always has something sane to fall back on.

: "${TERMLAB_HOME:="$(cd "$(dirname "${(%):-%N}")/../.." && pwd)"}"

termlab_load_config() {
    [ -f "$TERMLAB_HOME/config.example" ] && source "$TERMLAB_HOME/config.example"
    [ -f "$TERMLAB_HOME/config" ] && source "$TERMLAB_HOME/config"
}

termlab_load_config
