#!/usr/bin/env bash
# Experiment: how pipes connect stdout of one process to stdin of the
# next, and how exit status only reflects the LAST command unless
# pipefail is set.
set -uo pipefail

echo "--- Without pipefail ---"
set +o pipefail
false | true
echo "exit code: $?  (reflects 'true', not 'false')"

echo
echo "--- With pipefail ---"
set -o pipefail
false | true
echo "exit code: $?  (reflects 'false', the first failure)"

echo
echo "--- A real pipeline ---"
printf "banana\napple\ncherry\n" | sort | nl
