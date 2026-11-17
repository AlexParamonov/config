#!/bin/bash
# Handy "external script" paste method: Handy passes the transcript as $1.
#
# Replaces Handy's built-in Shift+Insert method: on GNOME Wayland that method
# ends with `wl-copy --primary --clear`, which stuck on this session for 13
# minutes while Handy held its global paste lock, so every later dictation
# blocked silently behind it. Handy waits for this script too, so every helper
# below is bounded by timeout.
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"

text="${1:-}"
if [ -z "$text" ]; then
    echo "handy-paste: no transcript in \$1" >&2
    exit 1
fi

# Save what we are about to overwrite and hand it back at the end, so a
# dictation does not eat the user's copy. An empty selection makes wl-paste
# exit non-zero and write to stderr, which is what the exit status gates on.
saved=$(mktemp) || exit 1
trap 'rm -f "$saved"' EXIT
if timeout 1 wl-paste -n >"$saved" 2>/dev/null; then
    mime=text/plain
elif timeout 1 wl-paste --type image/png >"$saved" 2>/dev/null; then
    mime=image/png
else
    mime=
fi
primary=$(timeout 1 wl-paste --primary -n 2>/dev/null) || primary=

# Shift+Insert reads the primary selection in terminals (foot binds it there)
# and the clipboard in GUI apps, so put the transcript on both.
timeout 2 wl-copy -- "$text" || { echo "handy-paste: wl-copy failed" >&2; exit 1; }
timeout 2 wl-copy --primary -- "$text" || echo "handy-paste: primary selection unavailable" >&2

# The compositor must own the selection before the target app is asked for it.
sleep 0.2

# ydotool raw keycodes: KEY_LEFTSHIFT(42) + KEY_INSERT(110).
if ! timeout 2 ydotool key 42:1 110:1 110:0 42:0; then
    # Deliberately no restore here: the transcript stays on the clipboard so
    # the user can still paste it by hand.
    echo "handy-paste: ydotool failed (is ydotoold running?)" >&2
    exit 1
fi

# Give the target app time to read the selection before it goes back. This is
# Handy's paste_delay_after_ms setting for its own methods; change both together.
# shortcut: an empty selection comes back empty, not cleared, only for PRIMARY:
# `wl-copy --primary --clear` is the call that wedged Handy above. A trailing
# newline is dropped, since `wl-paste -n` trims one.
sleep 0.3
case "$mime" in
    text/plain) timeout 2 wl-copy <"$saved" ;;
    image/png) timeout 2 wl-copy --type image/png <"$saved" ;;
    *) timeout 2 wl-copy --clear ;;
esac
if [ -n "$primary" ]; then
    timeout 2 wl-copy --primary -- "$primary"
fi
