#!/usr/bin/env bash
# Runs the hexdocs CLI test suites. Exit 0 iff all pass.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

failures=0

for script in "$SCRIPT_DIR/../hexdocs" "$SCRIPT_DIR/../hexdocs-update" "$SCRIPT_DIR/../hexdocs-common.sh" "$SCRIPT_DIR/../../install.sh"; do
    if ! bash -n "$script"; then
        echo "SYNTAX ERROR in $script"
        failures=$((failures + 1))
    fi
done

for suite in "$SCRIPT_DIR/test-hexdocs.sh" "$SCRIPT_DIR/test-hexdocs-update.sh"; do
    echo "=== $(basename "$suite") ==="
    if bash "$suite"; then
        :
    else
        failures=$((failures + 1))
    fi
done

echo ""
if [ "$failures" -eq 0 ]; then
    echo "ALL TESTS PASSED"
else
    echo "$failures SUITE(S) FAILED"
fi
exit "$failures"
