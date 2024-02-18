#!/bin/sh

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# VSCODE_SETTING_DIR=~/Library/Application\ Support/Code/User
VSCODE_SETTING_DIR=~/.config/Code/User

rm "$VSCODE_SETTING_DIR/settings.json"
ln -s "$SCRIPT_DIR/settings.json" "${VSCODE_SETTING_DIR}/settings.json"

rm "$VSCODE_SETTING_DIR/keybindings.json"
ln -s "$SCRIPT_DIR/keybindings.json" "${VSCODE_SETTING_DIR}/keybindings.json"

# install extention
while IFS= read -r extension; do
	code --install-extension "$extension"
done <extensions

code --list-extensions >extensions
