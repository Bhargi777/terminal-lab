#!/usr/bin/env bash
# Experiment: driving macOS apps via AppleScript from the shell.
# Only touches Notification Center and reads the volume; nothing else.
set -euo pipefail

command -v osascript >/dev/null 2>&1 || { echo "osascript not found (macOS only)" >&2; exit 1; }

echo "Current output volume:"
osascript -e "output volume of (get volume settings)"

echo "Posting a notification..."
osascript -e 'display notification "hello from osascript.sh" with title "terminal-lab experiment"'

echo "Done. Check Notification Center."
