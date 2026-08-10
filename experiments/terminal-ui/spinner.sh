#!/usr/bin/env bash
# Experiment: a braille-dot spinner, the building block behind any
# "loading..." indicator in a CLI.
set -euo pipefail

frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
printf "\033[?25l"
trap 'printf "\033[?25h\n"' EXIT

for _ in {1..30}; do
    for f in "${frames[@]}"; do
        printf "\r%s working..." "$f"
        sleep 0.05
    done
done
printf "\rdone.        \n"
