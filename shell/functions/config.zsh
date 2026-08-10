# Loads terminal-lab config with safe fallbacks.
# Personal values live in $BHARGI_HOME/config (gitignored); defaults come
# from config.example so the CLI always has something sane to fall back on.

: "${BHARGI_HOME:="$(cd "$(dirname "${(%):-%N}")/../.." && pwd)"}"

bhargi_load_config() {
    [ -f "$BHARGI_HOME/config.example" ] && source "$BHARGI_HOME/config.example"
    [ -f "$BHARGI_HOME/config" ] && source "$BHARGI_HOME/config"
}

bhargi_load_config
