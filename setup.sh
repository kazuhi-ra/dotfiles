#!/bin/bash
# エントリポイント②: 本セットアップ(ssh 設定後)。
# 各マシンは install_packages.sh / languages.sh / editor.sh を実装している前提
# (規約の充足は ./check.sh で確認できる)。
set -eu

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

MACHINE="$(resolve_machine)"
echo "マシンプロファイル: $MACHINE"

for step in install_packages languages editor; do
  "$ROOT_DIR/$MACHINE/$step.sh"
done

echo "お疲れ様でした。"
