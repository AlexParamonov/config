#!/usr/bin/env bash
# Shared helpers for the hexdocs CLI wrappers (extra/hexdocs, extra/hexdocs-update).
# Sourced by each wrapper; install.sh copies it to ~/.local/bin/ alongside them.

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
