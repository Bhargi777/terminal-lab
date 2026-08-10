# Development helper functions, refactored from the personal .zshrc.

# Make a directory and cd into it.
mkcd() {
    if [ -z "$1" ]; then
        echo "Usage: mkcd <directory>" >&2
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Clone a repo and cd into it.
gc() {
    if [ -z "$1" ]; then
        echo "Usage: gc <repository-url>" >&2
        return 1
    fi

    git clone "$1" || return 1

    local repo="${1##*/}"
    repo="${repo%.git}"
    cd "$repo" || return 1
}

# Create + activate a venv in the current directory.
venv() {
    if [ ! -d .venv ]; then
        python3 -m venv .venv || return 1
    fi
    source .venv/bin/activate
}

# Open a Google search from the terminal.
google() {
    if [ -z "$1" ]; then
        echo "Usage: google <query>" >&2
        return 1
    fi
    open "https://www.google.com/search?q=$(printf '%s' "$*" | sed 's/ /+/g')"
}
