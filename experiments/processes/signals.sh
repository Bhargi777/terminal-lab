#!/usr/bin/env bash
# Experiment: trapping signals. Sends SIGTERM to a background sleep of
# its own spawning only — never touches an unrelated process.
set -euo pipefail

sleep 30 &
pid=$!
echo "Spawned sleep 30 as PID $pid"

trap 'echo "parent received SIGINT, killing child $pid"; kill "$pid" 2>/dev/null; exit 1' INT

sleep 1
echo "Sending SIGTERM to $pid"
kill -TERM "$pid"

wait "$pid" 2>/dev/null
echo "Child exit status: $?  (143 = 128 + SIGTERM's 15)"
