#!/usr/bin/env bash
# Shared test harness for the hexdocs CLI wrappers.
#
# Tests run the wrapper scripts with fake docker/curl/npm/hexdocs binaries
# prepended to PATH, so no container, network, or global npm state is touched.
# Fake behavior is driven by state files in $FAKE_STATE:
#   containers     lines "name:running|stopped" — docker ps inventory
#   ollama-ready   presence => GET /api/tags succeeds
#   model-available presence => GET /api/show succeeds
#   binary-mode    ok | connrefused | connrefused-once | fail | fail-once | fail-fetch | crash
#   no-ready       docker start/run do NOT make Ollama ready
#   run-fail       docker run exits non-zero
# Invocations are logged to $FAKE_LOG/*.log for outcome assertions.
set -uo pipefail

PASS=0
FAIL=0
CURRENT_TEST=""

TEST_DIR="$(mktemp -d)"
FAKE_BIN="$TEST_DIR/bin"
FAKE_NPM_ROOT="$TEST_DIR/npm-root"
FAKE_STATE="$TEST_DIR/state"
FAKE_LOG="$TEST_DIR/log"
mkdir -p "$FAKE_BIN" "$FAKE_NPM_ROOT/hexdocs-mcp/bin" "$FAKE_STATE" "$FAKE_LOG"
export FAKE_STATE FAKE_LOG FAKE_NPM_ROOT

t() { CURRENT_TEST="$1"; }
pass() { PASS=$((PASS + 1)); }
fail() { FAIL=$((FAIL + 1)); echo "FAIL [$CURRENT_TEST]: $*"; }

assert_eq() { # actual expected label
    if [ "$1" = "$2" ]; then pass; else fail "$3: expected [$2] got [$1]"; fi
}
assert_contains() { # haystack needle label
    case "$1" in *"$2"*) pass ;; *) fail "$3: missing [$2] in: $1" ;; esac
}
assert_not_contains() { # haystack needle label
    case "$1" in *"$2"*) fail "$3: unexpected [$2] in: $1" ;; *) pass ;; esac
}
assert_file_contains() { # file needle label
    if [ -f "$1" ] && grep -qF "$2" "$1"; then pass; else fail "$3: file $1 missing [$2]"; fi
}
assert_file_line_count() { # file expected-count label
    local actual
    actual="$(grep -cF "$2" "$1" 2>/dev/null || true)"
    assert_eq "$actual" "$3" "$4"
}

summary() {
    echo ""
    echo "PASS: $PASS  FAIL: $FAIL"
    [ "$FAIL" -eq 0 ]
}

# --- fake binaries ---

cat > "$FAKE_BIN/docker" <<'FAKE'
#!/usr/bin/env bash
# Fake docker: container inventory in $FAKE_STATE/containers.
echo "docker $*" >> "$FAKE_LOG/docker.log"
cmd="$1"
shift
case "$cmd" in
    ps)
        all=""; name=""; fmt=""
        while [ $# -gt 0 ]; do
            case "$1" in
                -a) all="1" ;;
                --filter) name="${2#name=}"; shift ;;
                --format) fmt="$2"; shift ;;
            esac
            shift
        done
        while IFS= read -r line; do
            [ -n "$line" ] || continue
            cname="${line%%:*}"
            cstate="${line#*:}"
            [ -z "$all" ] && [ "$cstate" != "running" ] && continue
            [ -n "$name" ] && [ "$cname" != "$name" ] && continue
            [ "$fmt" = "{{.Names}}" ] && echo "$cname"
        done < "$FAKE_STATE/containers"
        ;;
    start)
        sed -i "s/^$2:.*/$2:running/" "$FAKE_STATE/containers"
        [ -f "$FAKE_STATE/no-ready" ] || touch "$FAKE_STATE/ollama-ready"
        ;;
    stop)
        sed -i "s/^$2:.*/$2:stopped/" "$FAKE_STATE/containers"
        rm -f "$FAKE_STATE/ollama-ready"
        ;;
    rm)
        # Ignore -f: the fake state file has no running-protection to force through.
        name=""
        while [ $# -gt 0 ]; do
            case "$1" in
                -f) ;;
                *) name="$1" ;;
            esac
            shift
        done
        sed -i "/^${name}:/d" "$FAKE_STATE/containers"
        ;;
    run)
        name=""; image=""
        while [ $# -gt 0 ]; do
            case "$1" in
                --name) name="$2"; shift ;;
                -d) ;;
                -*) ;;
                *) image="$1" ;;
            esac
            shift
        done
        if [ -f "$FAKE_STATE/run-fail" ]; then
            echo "docker: Error response from daemon: failed to start container" >&2
            exit 1
        fi
        if grep -q "^$name:" "$FAKE_STATE/containers"; then
            echo "docker: Error response from daemon: Conflict. The container name \"/$name\" is already in use" >&2
            exit 125
        fi
        echo "$name:running" >> "$FAKE_STATE/containers"
        [ -f "$FAKE_STATE/no-ready" ] || touch "$FAKE_STATE/ollama-ready"
        ;;
esac
FAKE
chmod +x "$FAKE_BIN/docker"

cat > "$FAKE_BIN/curl" <<'FAKE'
#!/usr/bin/env bash
echo "curl $*" >> "$FAKE_LOG/curl.log"
case "$*" in
    *"/api/tags"*) [ -f "$FAKE_STATE/ollama-ready" ] && exit 0 || exit 7 ;;
    *"/api/show"*) [ -f "$FAKE_STATE/model-available" ] && exit 0 || exit 1 ;;
    *"/api/pull"*)
        if [ -f "$FAKE_STATE/pull-fail" ]; then
            echo '{"error":"model not found"}'
        else
            echo '{"status":"success"}'
        fi
        ;;
esac
exit 0
FAKE
chmod +x "$FAKE_BIN/curl"

cat > "$FAKE_BIN/npm" <<'FAKE'
#!/usr/bin/env bash
echo "npm $*" >> "$FAKE_LOG/npm.log"
echo "npm $*" >> "$FAKE_LOG/order.log"
case "$1" in
    root) echo "$FAKE_NPM_ROOT" ;;
esac
exit 0
FAKE
chmod +x "$FAKE_BIN/npm"

cat > "$FAKE_BIN/mix" <<'FAKE'
#!/usr/bin/env bash
# Fake mix. Logs argv; fails when $FAKE_STATE/mix-fail exists.
echo "mix $*" >> "$FAKE_LOG/mix.log"
echo "mix $*" >> "$FAKE_LOG/order.log"
if [ -f "$FAKE_STATE/mix-fail" ]; then
    echo "** (Mix) command deps.get failed" >&2
    exit 1
fi
exit 0
FAKE
chmod +x "$FAKE_BIN/mix"

cat > "$FAKE_NPM_ROOT/hexdocs-mcp/bin/hexdocs_mcp_linux" <<'FAKE'
#!/usr/bin/env bash
# Fake hexdocs binary. Logs argv; behavior from $FAKE_STATE/binary-mode.
# Mirrors the real binary: exits 0 even on connection failure.
echo "hexdocs_mcp_linux $*" >> "$FAKE_LOG/binary.log"
echo "hexdocs_mcp_linux $*" >> "$FAKE_LOG/order.log"
mode="$(cat "$FAKE_STATE/binary-mode" 2>/dev/null || echo ok)"
case "$mode" in
    connrefused)
        echo "Error generating query embedding: {:error, %Req.TransportError{reason: :econnrefused}}"
        echo "No results found."
        ;;
    connrefused-once)
        echo "ok" > "$FAKE_STATE/binary-mode"
        echo "Error generating query embedding: {:error, %Req.TransportError{reason: :econnrefused}}"
        echo "No results found."
        ;;
    fail-fetch)
        echo "fetch failed for app" >&2
        exit 1
        ;;
    fail)
        echo "Error: something went wrong" >&2
        exit 1
        ;;
    crash)
        echo "Error: something went wrong" >&2
        exit 2
        ;;
    fail-once)
        echo "ok" > "$FAKE_STATE/binary-mode"
        echo "fetch failed for app" >&2
        exit 1
        ;;
    ok)
        echo "Searching for \"test\" in all packages (latest versions only)..."
        echo "✓ Found 2 results:"
        echo "  Package: jido"
        echo "  URL: https://hexdocs.pm/jido/core-loop.html"
        ;;
esac
exit 0
FAKE
chmod +x "$FAKE_NPM_ROOT/hexdocs-mcp/bin/hexdocs_mcp_linux"

# --- test setup helpers ---

setup_fakes() {
    reset_state
    export PATH="$FAKE_BIN:$PATH"
}

reset_state() {
    : > "$FAKE_STATE/containers"
    rm -f "$FAKE_STATE/ollama-ready" "$FAKE_STATE/model-available" \
          "$FAKE_STATE/no-ready" "$FAKE_STATE/run-fail" "$FAKE_STATE/pull-fail" "$FAKE_STATE/mix-fail"
    echo ok > "$FAKE_STATE/binary-mode"
    : > "$FAKE_LOG/docker.log"
    : > "$FAKE_LOG/curl.log"
    : > "$FAKE_LOG/npm.log"
    : > "$FAKE_LOG/mix.log"
    : > "$FAKE_LOG/binary.log"
    : > "$FAKE_LOG/order.log"
}

state_container() { # name running|stopped
    sed -i "/^$1:/d" "$FAKE_STATE/containers"
    echo "$1:$2" >> "$FAKE_STATE/containers"
}

make_repo() { # path app1 app2 ...
    local dir="$1"
    shift
    local app
    for app in "$@"; do
        mkdir -p "$dir/apps/$app"
        touch "$dir/apps/$app/mix.exs"
    done
}
