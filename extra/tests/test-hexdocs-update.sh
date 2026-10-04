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
assert_file_contains "$FAKE_STATE/fetched-docs" "apps/agent_loop/mix.exs fake_dep" "first app docs processed"
assert_file_contains "$FAKE_STATE/fetched-docs" "apps/anagen_x/mix.exs fake_dep" "second app docs processed"

t "update: fetches apps from every repo arg"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
( source "$UPDATE"; main "$REPO1" "$REPO2" ) >/dev/null 2>&1
assert_file_contains "$FAKE_STATE/fetched-docs" "apps/book_companion/mix.exs fake_dep" "book-companion docs processed"

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

t "update: reports clear error when model pull fails"
reset_state
state_container anagen-x-ollama stopped
rm -f "$FAKE_STATE/model-available"
touch "$FAKE_STATE/pull-fail"
out="$( source "$UPDATE"; main "$REPO1" 2>&1 )"
code=$?
assert_eq "$code" 1 "exit code"
assert_contains "$out" "failed to pull model" "clear model pull error"
assert_file_contains "$FAKE_LOG/docker.log" "docker start anagen-x-ollama" "cpu restored after model failure"

t "update: removes a stale GPU container before starting a fresh one"
reset_state
state_container anagen-x-ollama stopped
state_container anagen-x-ollama-gpu stopped
touch "$FAKE_STATE/model-available"
( source "$UPDATE"; main "$REPO1" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 0 "exit code"
assert_file_contains "$FAKE_LOG/docker.log" "docker rm -f anagen-x-ollama-gpu" "stale gpu container removed"

t "update: continues package fetches after one package fails"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
printf 'hackney\ngood_dep\n' > "$FAKE_STATE/dependencies"
echo hackney > "$FAKE_STATE/failing-package"
( source "$UPDATE"; main "$REPO2" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 0 "exit code"
assert_file_contains "$FAKE_STATE/failed-docs" "apps/book_companion/mix.exs hackney" "failed package recorded"
assert_file_contains "$FAKE_STATE/fetched-docs" "apps/book_companion/mix.exs good_dep" "later package processed successfully"

t "update: falls back to bulk fetch when package enumeration fails"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available" "$FAKE_STATE/mix-run-fail"
out="$( source "$UPDATE"; main "$REPO2" 2>&1 )"
code=$?
assert_eq "$code" 0 "exit code"
assert_contains "$out" "could not list Hex packages" "enumeration warning"
assert_file_contains "$FAKE_STATE/bulk-fetches" "apps/book_companion/mix.exs" "bulk fetch fallback processed"

t "update: continues fetching remaining apps when one fetch fails"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
echo fail-once > "$FAKE_STATE/binary-mode"
( source "$UPDATE"; main "$REPO1" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 0 "exit code"
assert_file_contains "$FAKE_STATE/failed-docs" "apps/agent_loop/mix.exs fake_dep" "first app fetch failed"
assert_file_contains "$FAKE_STATE/fetched-docs" "apps/anagen_x/mix.exs fake_dep" "later app processed after earlier failure"

t "update: passes --force through to every fetch and still restores CPU Ollama"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
( source "$UPDATE"; main --force "$REPO1" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 0 "exit code"
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux fetch fake_dep --project apps/agent_loop/mix.exs --model qwen3-embedding:4b --force" "force passed to app 1"
assert_file_contains "$FAKE_LOG/binary.log" "hexdocs_mcp_linux fetch fake_dep --project apps/anagen_x/mix.exs --model qwen3-embedding:4b --force" "force passed to app 2"
assert_file_contains "$FAKE_LOG/docker.log" "docker start anagen-x-ollama" "cpu restored on exit with --force"

t "update: runs mix deps.get in each repo before fetching that repo's apps"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
( source "$UPDATE"; main "$REPO1" "$REPO2" ) >/dev/null 2>&1
code=$?
assert_eq "$code" 0 "exit code"
assert_file_line_count "$FAKE_LOG/mix.log" "mix deps.get" 2 "deps.get run once per repo"
mix1="$(grep -nF "mix deps.get" "$FAKE_LOG/order.log" | head -1 | cut -d: -f1)"
fetch1="$(grep -nF "hexdocs_mcp_linux fetch" "$FAKE_LOG/order.log" | head -1 | cut -d: -f1)"
if [ -n "$mix1" ] && [ -n "$fetch1" ] && [ "$mix1" -lt "$fetch1" ]; then pass; else fail "first deps.get must precede first fetch"; fi
mix2="$(grep -nF "mix deps.get" "$FAKE_LOG/order.log" | sed -n '2p' | cut -d: -f1)"
fetch_bc="$(grep -nF "book_companion" "$FAKE_LOG/order.log" | head -1 | cut -d: -f1)"
if [ -n "$mix2" ] && [ -n "$fetch_bc" ] && [ "$mix2" -lt "$fetch_bc" ]; then pass; else fail "book-companion deps.get must precede its fetch"; fi

t "update: warns and continues when mix deps.get fails"
reset_state
state_container anagen-x-ollama stopped
touch "$FAKE_STATE/model-available"
touch "$FAKE_STATE/mix-fail"
out="$( source "$UPDATE"; main "$REPO1" 2>&1 )"
code=$?
assert_eq "$code" 0 "exit code"
assert_contains "$out" "mix deps.get failed" "warning printed"
assert_file_contains "$FAKE_STATE/fetched-docs" "apps/agent_loop/mix.exs fake_dep" "fetch still processed after deps.get failure"

t "update: unknown option is a usage error"
reset_state
out="$( source "$UPDATE"; main --bogus "$REPO1" 2>&1 )"
code=$?
assert_eq "$code" 2 "exit code"
assert_contains "$out" "unknown option" "error message"


t "update: --help prints usage without CPU restore noise"
reset_state
out="$( source "$UPDATE"; main --help 2>&1 )"
code=$?
assert_eq "$code" 0 "exit code"
assert_contains "$out" "Usage" "usage shown"
assert_not_contains "$out" "Restoring CPU Ollama" "no restore banner on help"
assert_file_line_count "$FAKE_LOG/docker.log" "docker" 0 "no container commands on help"

t "update: no-args usage prints usage without CPU restore noise"
reset_state
out="$( source "$UPDATE"; main 2>&1 )"
code=$?
assert_eq "$code" 2 "exit code"
assert_contains "$out" "Usage" "usage shown"
assert_not_contains "$out" "Restoring CPU Ollama" "no restore banner on usage error"
assert_file_line_count "$FAKE_LOG/docker.log" "docker" 0 "no container commands on usage error"

summary
