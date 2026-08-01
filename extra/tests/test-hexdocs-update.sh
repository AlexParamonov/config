#!/usr/bin/env bash
# Tests for extra/hexdocs-update (embedding fetch wrapper).
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
UPDATE="$SCRIPT_DIR/../hexdocs-update"

setup_fakes
source "$UPDATE"

REPO1="$TEST_DIR/repos/anagen-x"
REPO2="$TEST_DIR/repos/book-companion"
make_repo "$REPO1" agent_loop anagen_x
make_repo "$REPO2" book_companion

t "update: swaps to GPU Ollama, fetches apps, restores CPU Ollama"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
( source "$UPDATE"; main "$REPO1" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 0 "exit code"
assert_file_contains "$FAKE_LOG/npm.log" "npm update -g hexdocs-mcp" "npm package updated"
assert_file_contains "$FAKE_LOG/docker.log" "docker stop anagen-x-ollama" "cpu container stopped"
assert_file_contains "$FAKE_LOG/docker.log" "docker run -d --name anagen-x-ollama-gpu" "gpu container started"
assert_file_contains "$FAKE_LOG/docker.log" "docker stop anagen-x-ollama-gpu" "gpu stopped in cleanup"
assert_file_contains "$FAKE_LOG/docker.log" "docker start anagen-x-ollama" "cpu restored in cleanup"
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux fetch --project apps/agent_loop/mix.exs --model qwen3-embedding:4b" "fetched app 1"
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux fetch --project apps/anagen_x/mix.exs --model qwen3-embedding:4b" "fetched app 2"

t "update: fetches apps from every repo arg"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
( source "$UPDATE"; main "$REPO1" "$REPO2" ) >/dev/null 2>&1
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux fetch --project apps/book_companion/mix.exs --model qwen3-embedding:4b" "book-companion app fetched"

t "update: npm update runs before any fetch"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
( source "$UPDATE"; main "$REPO1" ) >/dev/null 2>&1
npm_line="$(grep -nF "npm update" "$FAKE_LOG/order.log" | head -1 | cut -d: -f1)"
fetch_line="$(grep -nF "hexdocs_mcp_linux fetch" "$FAKE_LOG/order.log" | head -1 | cut -d: -f1)"
assert_eq "$([ -n "$npm_line" ] && echo yes || echo no)" "yes" "npm update ran"
if [ -n "$npm_line" ] && [ -n "$fetch_line" ]; then
    [ "$npm_line" -lt "$fetch_line" ] && pass || fail "npm update must precede fetches"
else
    fail "missing npm update or fetch log lines"
fi

t "update: unknown repo errors out"
reset_state
out="$(main /nonexistent/repo 2>&1)"
code=$?
assert_eq "$code" 1 "exit code"
assert_contains "$out" "not found" "error message"

t "update: pulls embedding model when missing"
reset_state
state_container anagen-x-ollama stopped
rm -f "$FAKE_STATE/model-available"
( source "$UPDATE"; main "$REPO1" ) >/dev/null 2>&1
assert_file_contains "$FAKE_LOG/curl.log" "/api/pull" "model pull requested"

t "update: errors and restores CPU Ollama when GPU never becomes ready"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
touch "$FAKE_STATE/no-ready"
( source "$UPDATE"; OLLAMA_READY_TIMEOUT=2 main "$REPO1" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 1 "exit code"
assert_file_contains "$FAKE_LOG/docker.log" "docker start anagen-x-ollama" "cpu restored after failure"

t "update: errors and restores when GPU container fails to start"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
touch "$FAKE_STATE/run-fail"
( source "$UPDATE"; main "$REPO1" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 1 "exit code"
assert_file_contains "$FAKE_LOG/docker.log" "docker start anagen-x-ollama" "cpu restored after failure"

summary
