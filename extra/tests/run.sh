#!/usr/bin/env bash
# Runs the extra/ CLI test suites. Exit 0 iff all pass.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

failures=0

# test-handy-paste.sh is syntax-checked only: it needs a live Wayland session,
# sends real keystrokes and takes over the clipboard, so run it by hand.
for script in "$SCRIPT_DIR/../hexdocs" "$SCRIPT_DIR/../hexdocs-update" "$SCRIPT_DIR/../hexdocs-common.sh" "$SCRIPT_DIR/../../install.sh" "$SCRIPT_DIR/../handy-paste.sh" "$SCRIPT_DIR/test-handy-paste.sh"; do
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
