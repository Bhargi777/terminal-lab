#!/usr/bin/env bash
# Experiment: exit codes as the shell's only channel for pass/fail,
# and how && / || chain on them.
set -uo pipefail

true; echo "true exits: $?"
false; echo "false exits: $?"

ls /definitely/not/a/real/path 2>/dev/null; echo "ls on missing path exits: $?"

echo "--- && chains only on success ---"
true && echo "ran because previous succeeded"
false && echo "this should not print"

echo "--- || chains only on failure ---"
false || echo "ran because previous failed"

echo "--- custom exit codes ---"
( exit 42 ); echo "subshell exited: $?"
