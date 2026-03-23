#!/bin/bash
# Qwen Code with LSP auto-configuration
# Creates .lsp.json symlink in project root if missing

set -e

# Find project root (git workspace)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

# Create symlink if in git workspace and .lsp.json doesn't exist
if [ -n "$PROJECT_ROOT" ] && [ ! -e "$PROJECT_ROOT/.lsp.json" ] && [ -f "$HOME/.qwen/.lsp.json" ]; then
    ln -s "$HOME/.qwen/.lsp.json" "$PROJECT_ROOT/.lsp.json"
fi

# Run qwen with LSP enabled
command qwen --experimental-lsp "$@"
