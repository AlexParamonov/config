#!/usr/bin/env bash
# Tests for extra/hexdocs (search wrapper).
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
HEXDOCS="$SCRIPT_DIR/../hexdocs"

setup_fakes
source "$HEXDOCS"

t "search: works when Ollama is already running"
reset_state
state_container anagen-x-ollama running
touch "$FAKE_STATE/ollama-ready"
echo ok > "$FAKE_STATE/binary-mode"
out="$(main search "agent loop")"
code=$?
assert_eq "$code" 0 "exit code"
assert_contains "$out" "Found 2 results" "results printed"
assert_file_contains "$FAKE_LOG/binary.log" \
    "hexdocs_mcp_linux search --query agent loop --model qwen3-embedding:4b --limit 5" \
    "default args (query, model, limit 5)"
assert_file_line_count "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search" 1 "no retry on success"

t "search: auto-starts Ollama when container is stopped"
reset_state
state_container anagen-x-ollama stopped
rm -f "$FAKE_STATE/ollama-ready"
echo connrefused-once > "$FAKE_STATE/binary-mode"
out="$(main search "agent loop")"
code=$?
assert_eq "$code" 0 "exit code after recovery"
assert_contains "$out" "Found 2 results" "retry succeeded"
assert_file_contains "$FAKE_LOG/docker.log" "docker start anagen-x-ollama" "container started"
assert_file_line_count "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search" 2 "search retried once"

t "search: reports error when container does not exist"
reset_state
echo connrefused > "$FAKE_STATE/binary-mode"
out="$(main search "agent loop" 2>&1)"
code=$?
assert_eq "$code" 1 "exit code"
assert_contains "$out" "does not exist" "clear error"
assert_file_line_count "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search" 1 "no retry when unrecoverable"

t "search: reports error when Ollama never becomes ready"
reset_state
state_container anagen-x-ollama stopped
rm -f "$FAKE_STATE/ollama-ready"
touch "$FAKE_STATE/no-ready"
echo connrefused > "$FAKE_STATE/binary-mode"
out="$(OLLAMA_READY_TIMEOUT=2 main search "agent loop" 2>&1)"
code=$?
assert_eq "$code" 1 "exit code"
assert_contains "$out" "did not become ready" "timeout error"

t "search: --package scopes to one package"
reset_state
state_container anagen-x-ollama running
touch "$FAKE_STATE/ollama-ready"
main search "agent loop" --package jido >/dev/null
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search jido --query" \
    "package passed positionally"

t "search: --version scopes to a version"
reset_state
state_container anagen-x-ollama running
touch "$FAKE_STATE/ollama-ready"
main search "agent loop" --version 1.0.0 >/dev/null
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search --version 1.0.0 --query agent loop" \
    "version flag passed through"

t "search: --limit is honored"
reset_state
state_container anagen-x-ollama running
touch "$FAKE_STATE/ollama-ready"
main search "agent loop" --limit 10 >/dev/null
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search --query agent loop --model qwen3-embedding:4b --limit 10" \
    "limit 10 passed through"

t "search: missing query is a usage error"
reset_state
out="$(main search 2>&1)"
code=$?
assert_eq "$code" 2 "exit code"
assert_contains "$out" "Usage" "usage shown"

t "search: unknown option is a usage error"
reset_state
out="$(main search "agent loop" --bogus 2>&1)"
code=$?
assert_eq "$code" 2 "exit code"
assert_contains "$out" "unknown option" "error message"

t "search: missing binary is reported with a fix hint"
reset_state
mv "$FAKE_NPM_ROOT/hexdocs-mcp/bin/hexdocs_mcp_linux" "$FAKE_NPM_ROOT/hexdocs-mcp/bin/.moved"
out="$(main search "agent loop" 2>&1)"
code=$?
mv "$FAKE_NPM_ROOT/hexdocs-mcp/bin/.moved" "$FAKE_NPM_ROOT/hexdocs-mcp/bin/hexdocs_mcp_linux"
assert_eq "$code" 1 "exit code"
assert_contains "$out" "not found" "clear error"
assert_contains "$out" "npm update -g hexdocs-mcp" "fix hint"

t "search: non-connection failure is not retried and propagates its exit code"
reset_state
state_container anagen-x-ollama running
touch "$FAKE_STATE/ollama-ready"
echo crash > "$FAKE_STATE/binary-mode"
out="$(main search "agent loop" 2>&1)"
code=$?
assert_eq "$code" 2 "exit code propagated"
assert_contains "$out" "something went wrong" "binary error shown"
assert_not_contains "$out" "attempting recovery" "no misleading recovery message"
assert_file_line_count "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search" 1 "no retry on non-connection failure"

t "search: exit 1 without connection error is not treated as a connection error"
reset_state
state_container anagen-x-ollama running
touch "$FAKE_STATE/ollama-ready"
echo fail > "$FAKE_STATE/binary-mode"
out="$(main search "agent loop" 2>&1)"
code=$?
assert_eq "$code" 1 "exit code propagated"
assert_not_contains "$out" "attempting recovery" "no misleading recovery message"
assert_file_line_count "$FAKE_LOG/binary.log" "hexdocs_mcp_linux search" 1 "no retry"


t "search: --help prints usage without restore or recovery noise"
reset_state
out="$(main --help 2>&1)"
code=$?
assert_eq "$code" 0 "exit code"
assert_contains "$out" "Usage" "usage shown"
assert_not_contains "$out" "Restoring" "no restore noise on help"
assert_not_contains "$out" "connection error" "no recovery noise on help"

t "search: no command prints usage without restore noise"
reset_state
out="$(main 2>&1)"
code=$?
assert_eq "$code" 2 "exit code"
assert_contains "$out" "Usage" "usage shown"
assert_not_contains "$out" "Restoring" "no restore noise on missing command"

summary
