#!/usr/bin/env zsh
# bhargi git — Git helpers. Never runs a destructive operation
# (reset --hard, clean -fd, force push) automatically; "cleanup" only
# ever prints what it would remove.

set -o pipefail

_bhargi_require_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        echo "Not inside a Git repository." >&2
        return 1
    }
}

cmd_status() {
    _bhargi_require_repo || return 1
    git status -sb
}

cmd_log() {
    _bhargi_require_repo || return 1
    local n="${1:-10}"
    git log --oneline --decorate -n "$n"
}

cmd_branches() {
    _bhargi_require_repo || return 1
    git branch -vv
}

cmd_cleanup() {
    _bhargi_require_repo || return 1
    echo "Merged local branches (safe to delete, not deleted automatically):"
    git branch --merged | grep -v -E '^\*|main|master' || echo "  none"
    echo
    echo "Untracked files git clean would remove (dry run, nothing deleted):"
    git clean -ndx
}

cmd_info() {
    _bhargi_require_repo || return 1
    echo "Repo    : $(basename "$(git rev-parse --show-toplevel)")"
    echo "Branch  : $(git rev-parse --abbrev-ref HEAD)"
    echo "Remote  : $(git remote get-url origin 2>/dev/null || echo 'none')"
    echo "Commits : $(git rev-list --count HEAD 2>/dev/null)"
    echo "Dirty   : $(git status --porcelain | wc -l | tr -d ' ') changed file(s)"
}

case "${1:-status}" in
    status)   cmd_status ;;
    log)      shift; cmd_log "$@" ;;
    branches) cmd_branches ;;
    cleanup)  cmd_cleanup ;;
    info)     cmd_info ;;
    -h|--help|help)
        cat <<EOF
bhargi git [subcommand]
  status (default)   short status
  log [n]            last n commits (default 10)
  branches           local branches with tracking info
  cleanup            dry-run report of merged branches / untracked files
  info               repo summary
EOF
        ;;
    *) echo "Unknown git subcommand: $1" >&2; exit 1 ;;
esac
