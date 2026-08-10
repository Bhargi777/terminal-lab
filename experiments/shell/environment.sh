#!/usr/bin/env bash
# Experiment: environment variable scope — exported vars pass to child
# processes, plain shell vars do not.
set -euo pipefail

PLAIN_VAR="only in this shell"
export EXPORTED_VAR="visible to children"

echo "In this shell:"
echo "  PLAIN_VAR=$PLAIN_VAR"
echo "  EXPORTED_VAR=$EXPORTED_VAR"

echo
echo "In a child process (bash -c):"
bash -c 'echo "  PLAIN_VAR=${PLAIN_VAR:-<unset>}"; echo "  EXPORTED_VAR=${EXPORTED_VAR:-<unset>}"'
