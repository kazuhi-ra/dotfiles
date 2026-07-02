#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(uname)" = "Darwin" ]; then
	VSCODE_SETTING_DIR="$HOME/Library/Application Support/Code/User"
else
	VSCODE_SETTING_DIR="$HOME/.config/Code/User"
fi

mkdir -p "$VSCODE_SETTING_DIR"
ln -fnsv "$SCRIPT_DIR/settings.json" "$VSCODE_SETTING_DIR/settings.json"
ln -fnsv "$SCRIPT_DIR/keybindings.json" "$VSCODE_SETTING_DIR/keybindings.json"

# install extensions
while IFS= read -r extension; do
	code --install-extension "$extension"
done <"$SCRIPT_DIR/extensions"

# extensions は「インストールすべき拡張のマニフェスト」であり、自動では書き戻さない
# (実行のたびにマシンの現状で上書きすると diff が揺れるため)。
# 現在の拡張一覧をマニフェストに固定したいときだけ --freeze を付けて実行する。
if [ "${1:-}" = "--freeze" ]; then
	code --list-extensions >"$SCRIPT_DIR/extensions"
	echo "extensions を現在のインストール状態で更新しました"
fi
