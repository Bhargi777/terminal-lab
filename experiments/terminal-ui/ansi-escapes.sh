#!/usr/bin/env bash
# Experiment: raw ANSI escape sequences for cursor movement and screen
# clearing. Safe to run — only touches the current terminal's display.
set -euo pipefail

echo "Cursor + screen control demo. Press enter after each step."

read -r
printf "\033[2J\033[H"          # clear screen, cursor to home
echo "Cleared screen, cursor at (1,1)"

read -r
printf "\033[5;10HHello at row 5, col 10"

read -r
printf "\033[10;1H"
printf "\033[1mBold\033[0m \033[4mUnderline\033[0m \033[7mInverse\033[0m\n"

read -r
printf "\n\033[?25l"            # hide cursor
echo "Cursor hidden. Press enter to show it again."
read -r
printf "\033[?25h"              # show cursor
echo "Done."
