#!/usr/bin/env bash
# Experiment: the progress bar from the original .zshrc, extracted as a
# standalone, reusable script instead of living inline at shell startup.
set -euo pipefail

width=$(tput cols)
title="TERMINAL LAB"
bar_width=40

clear
title_padding=$(( (width - ${#title}) / 2 ))
printf "%*s%s\n\n" "$title_padding" "" "$title"

bar_padding=$(( (width - bar_width - 8) / 2 ))
for i in $(seq 0 40); do
    filled=$i
    empty=$((bar_width - i))
    percent=$((i * 100 / bar_width))
    printf "\r%*s[" "$bar_padding" ""
    printf "%${filled}s" "" | tr ' ' '█'
    printf "%${empty}s" "" | tr ' ' '░'
    printf "] %3d%%" "$percent"
    sleep 0.02
done
echo
