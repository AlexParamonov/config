#!/usr/bin/env bash
# Shared config and helpers for the hexdocs CLI wrappers (extra/hexdocs,
# extra/hexdocs-update). Sourced by each wrapper; install.sh copies it to
# ~/.local/bin/ alongside them.

# Model used for both fetching embeddings and searching. Searches must use
# the model the docs were embedded with, so it is shared rather than overridden.
MODEL="qwen3-embedding:4b"
OLLAMA_URL="http://localhost:11434"
# CPU Ollama container definition, shared by the search wrapper (which
# creates it on demand) and hexdocs-update (which swaps it for the GPU one).
OLLAMA_VOLUME="anagen-x_ollama_data"
OLLAMA_IMAGE="ollama/ollama:latest"

# Resolve the hexdocs_mcp_linux binary via the global npm root, so the active
# asdf node version is used without hardcoding any path to it.
hexdocs_bin() {
    local root bin
    root="$(npm root -g 2>/dev/null)" || {
        echo "Error: npm not found in PATH (install nodejs via asdf first)" >&2
        return 1
    }
    bin="$root/hexdocs-mcp/bin/hexdocs_mcp_linux"
    if [ ! -x "$bin" ]; then
        echo "Error: hexdocs binary not found at $bin" >&2
        echo "Run: npm update -g hexdocs-mcp" >&2
        return 1
    fi
    echo "$bin"
}

ollama_ready() {
    curl -s --max-time 2 "$OLLAMA_URL/api/tags" >/dev/null 2>&1
}

# Poll until the Ollama API responds or the timeout elapses. The caller owns
# any user-facing "waiting" banner; this only prints on failure.
wait_ollama() {
    local i
    for i in $(seq 1 "${OLLAMA_READY_TIMEOUT:-60}"); do
        ollama_ready && return 0
        sleep 1
    done
    echo "Error: Ollama did not become ready within ${OLLAMA_READY_TIMEOUT:-60}s" >&2
    return 1
}
