#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Updating all git submodules..."
git submodule update --remote --init --recursive

echo ""
echo "Submodule status:"
git submodule status

echo ""
echo "Changes to commit:"
git status --short

echo ""
echo "Done!"
