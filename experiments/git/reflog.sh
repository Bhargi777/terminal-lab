#!/usr/bin/env bash
# Experiment: git reflog as the safety net behind "I deleted a commit".
# Builds a throwaway repo in /tmp — never touches a real repository.
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

git init -q -b main
git config user.email "lab@example.com"
git config user.name "terminal-lab"

echo "one" >f.txt && git add f.txt && git commit -qm "first commit"
echo "two" >f.txt && git commit -qam "second commit"
echo "three" >f.txt && git commit -qam "third commit"

echo "Log before reset:"
git log --oneline

git reset --hard HEAD~2
echo
echo "Log after 'git reset --hard HEAD~2':"
git log --oneline

echo
echo "But reflog still remembers everything:"
git reflog

lost_sha=$(git reflog | awk '/third commit/ {print $1; exit}')
echo
echo "Recovering the 'lost' third commit via: git reset --hard $lost_sha"
git reset --hard "$lost_sha" -q
git log --oneline
