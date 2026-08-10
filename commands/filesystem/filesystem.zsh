#!/usr/bin/env zsh
# termlab files — filesystem inspection. No destructive operations here;
# deletion is deliberately out of scope for this module.

set -o pipefail

cmd_summary() {
    echo "cwd  : $(pwd)"
    echo "items: $(ls -1A | wc -l | tr -d ' ')"
    echo
    ls -lhA
}

cmd_large() {
    local dir="${1:-.}"
    local n="${2:-10}"
    echo "Top $n largest files under $dir:"
    find "$dir" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n "$n"
}

cmd_search() {
    local pattern="$1"
    local dir="${2:-.}"
    if [ -z "$pattern" ]; then
        echo "Usage: termlab files search <pattern> [dir]" >&2
        return 1
    fi
    find "$dir" -iname "*$pattern*" 2>/dev/null
}

cmd_info() {
    local target="$1"
    if [ -z "$target" ]; then
        echo "Usage: termlab files info <path>" >&2
        return 1
    fi
    if [ ! -e "$target" ]; then
        echo "No such file or directory: $target" >&2
        return 1
    fi
    stat -x "$target" 2>/dev/null || stat "$target"
    echo
    file "$target"
    if [ -L "$target" ]; then
        echo "symlink -> $(readlink "$target")"
    fi
}

case "${1:-summary}" in
    summary) cmd_summary ;;
    large)   shift; cmd_large "$@" ;;
    search)  shift; cmd_search "$@" ;;
    info)    shift; cmd_info "$@" ;;
    -h|--help|help)
        cat <<EOF
termlab files [subcommand]
  summary (default)     current directory listing
  large [dir] [n]       n largest files under dir (default: ., 10)
  search <pattern> [dir] find files matching a name pattern
  info <path>            stat + file type + symlink target
EOF
        ;;
    *) echo "Unknown files subcommand: $1" >&2; exit 1 ;;
esac
