#!/usr/bin/env bash
# Tests for extra/handy-paste.sh, the Handy external paste script.
#
# Deliberately not wired into run.sh: it drives a live Wayland session, sends
# one real Shift+Insert keystroke per case and takes over the clipboard, so it
# cannot run headless. Focus a scratch window first, since those keystrokes land
# wherever the desktop focus is. Run it by hand after any change to the paste
# script.
# helpers.sh is not sourced either, since it prepends fake docker/npm binaries
# to PATH for the hexdocs suites.
set -uo pipefail
PASTE="$HOME/.local/bin/handy-paste.sh"   # the path Handy is configured to run
PNG=/usr/share/icons/Yaru-bark/16x16/actions/folder-new.png
PASS=0
FAIL=0
CURRENT_TEST=""

t() { CURRENT_TEST="$1"; }
pass() { PASS=$((PASS + 1)); }
fail() { FAIL=$((FAIL + 1)); echo "FAIL [$CURRENT_TEST]: $*"; }
assert_eq() { # actual expected label
    if [ "$1" = "$2" ]; then pass; else fail "$3: got [$1], want [$2]"; fi
}
clipboard() { timeout 2 wl-paste -n 2>/dev/null || echo "<none>"; }
primary() { timeout 2 wl-paste --primary -n 2>/dev/null || echo "<none>"; }

if [ ! -x "$PASTE" ] || [ ! -f "$PNG" ]; then
    echo "CANNOT RUN: needs an installed $PASTE and a test image at $PNG"
    exit 1
fi

t "text clipboard and text selection both come back"
printf 'line1\nline2' | wl-copy
printf 'my-selection' | wl-copy --primary
timeout 20 "$PASTE" "TRANSCRIPT-1"
assert_eq "$?" 0 "exit code"
assert_eq "$(clipboard)" "$(printf 'line1\nline2')" "clipboard restored"
assert_eq "$(primary)" "my-selection" "primary restored"

t "an image on the clipboard survives a dictation"
wl-copy --type image/png <"$PNG"
timeout 20 "$PASTE" "TRANSCRIPT-2"
assert_eq "$?" 0 "exit code"
timeout 2 wl-paste --type image/png >/tmp/handy-paste-restored.png 2>/dev/null
assert_eq "$(cmp -s "$PNG" /tmp/handy-paste-restored.png && echo same || echo different)" \
    "same" "image bytes"

t "an empty clipboard stays empty"
wl-copy --clear
timeout 20 "$PASTE" "TRANSCRIPT-3"
assert_eq "$?" 0 "exit code"
assert_eq "$(clipboard)" "<none>" "clipboard still empty"

t "a launcher-like empty environment still pastes and restores"
printf 'env-probe-clip' | wl-copy
printf 'env-probe-sel' | wl-copy --primary
env -i PATH=/usr/bin:/bin HOME="$HOME" timeout 20 "$PASTE" "TRANSCRIPT-4"
assert_eq "$?" 0 "exit code"
assert_eq "$(clipboard)" "env-probe-clip" "clipboard restored without inherited env"
assert_eq "$(primary)" "env-probe-sel" "primary restored without inherited env"

t "missing transcript argument fails without touching the clipboard"
printf 'keep-me' | wl-copy
timeout 20 "$PASTE" >/dev/null 2>&1
assert_eq "$?" 1 "exit code"
assert_eq "$(clipboard)" "keep-me" "clipboard untouched"

echo ""
echo "PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
