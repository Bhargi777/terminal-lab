#!/usr/bin/env bash
# Experiment: Unix permission bits (rwx for owner/group/other) and
# chmod's numeric vs symbolic forms. Operates only inside a temp dir.
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

touch file.txt
echo "Default permissions:"; ls -l file.txt

chmod 600 file.txt
echo "After chmod 600 (owner read/write only):"; ls -l file.txt

chmod +x file.txt
echo "After chmod +x (execute bit added for all):"; ls -l file.txt

chmod u=rw,g=r,o= file.txt
echo "After chmod u=rw,g=r,o= (symbolic form):"; ls -l file.txt

echo
echo "stat octal mode: $(stat -f '%Mp%Lp' file.txt)"
