#!/bin/bash

VSCODE_EXT_DIR="$HOME/.vscode/extensions"
TARGET_DIR="$VSCODE_EXT_DIR/virex-syntax-1.0.0"

mkdir -p "$VSCODE_EXT_DIR"

echo "Installing Virex VS Code extension to: $TARGET_DIR"

if [ -d "$TARGET_DIR" ]; then
    echo "Extension already exists. Removing..."
    rm -rf "$TARGET_DIR"
fi

mkdir -p "$TARGET_DIR"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cp -r "$SCRIPT_DIR"/* "$TARGET_DIR"/ 2>/dev/null

if [ $? -ne 0 ]; then
    echo "Installation failed."
    exit 1
fi

echo "Installation successful: $TARGET_DIR"
echo ""
echo "Please restart VS Code or reload the window (Cmd+K Cmd+R on macOS, Ctrl+K Ctrl+R on Linux)."
