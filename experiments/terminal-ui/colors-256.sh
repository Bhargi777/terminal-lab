#!/usr/bin/env bash
# Experiment: print the 256-color ANSI palette to see what a given
# terminal emulator actually supports.
set -euo pipefail

for i in {0..255}; do
    printf "\033[38;5;%sm%3d\033[0m " "$i" "$i"
    (( (i + 1) % 16 == 0 )) && echo
done
