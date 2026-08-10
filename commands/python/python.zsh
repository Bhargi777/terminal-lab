#!/usr/bin/env zsh
# bhargi python — Python environment helpers.

set -o pipefail

_bhargi_py() {
    command -v python3 >/dev/null 2>&1 && echo python3 || { echo "python3 not found" >&2; return 1; }
}

cmd_info() {
    local py; py="$(_bhargi_py)" || return 1
    echo "Python  : $($py --version 2>&1)"
    echo "Path    : $(command -v "$py")"
    echo "Pip     : $($py -m pip --version 2>/dev/null || echo 'not available')"
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "Venv    : $VIRTUAL_ENV (active)"
    elif [ -d .venv ]; then
        echo "Venv    : .venv (present, not active)"
    else
        echo "Venv    : none"
    fi
}

cmd_venv() {
    local py; py="$(_bhargi_py)" || return 1
    if [ -d .venv ]; then
        echo ".venv already exists in $(pwd)"
    else
        "$py" -m venv .venv && echo "Created .venv. Run: source .venv/bin/activate"
    fi
}

cmd_packages() {
    local py; py="$(_bhargi_py)" || return 1
    "$py" -m pip list 2>/dev/null
}

cmd_project() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: bhargi python project <name>" >&2
        return 1
    fi
    if [ -e "$name" ]; then
        echo "$name already exists" >&2
        return 1
    fi
    mkdir -p "$name" && cd "$name" || return 1
    local py; py="$(_bhargi_py)" || return 1
    "$py" -m venv .venv
    cat > main.py <<'EOF'
def main():
    print("hello from bhargi python project")


if __name__ == "__main__":
    main()
EOF
    cat > requirements.txt <<'EOF'
EOF
    echo "Created project '$name' with .venv, main.py, requirements.txt"
}

case "${1:-info}" in
    info)     cmd_info ;;
    venv)     cmd_venv ;;
    packages) cmd_packages ;;
    project)  shift; cmd_project "$@" ;;
    -h|--help|help)
        cat <<EOF
bhargi python [subcommand]
  info (default)   interpreter, pip, and venv status
  venv             create .venv in the current directory
  packages         list installed packages (pip list)
  project <name>   scaffold a new dir with .venv + main.py
EOF
        ;;
    *) echo "Unknown python subcommand: $1" >&2; exit 1 ;;
esac
