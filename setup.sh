#!/bin/bash
# 本セットアップ(ssh 設定後)
set -eu

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

MACHINE="$(resolve_machine)"
echo "マシンプロファイル: $MACHINE"

for step in install_packages languages editor; do
  "$ROOT_DIR/$MACHINE/$step.sh"
done

# エージェント skill を各ツールへ配線（skills.toml 駆動）
if command -v python3 >/dev/null; then
  python3 "$ROOT_DIR/lib/link-skills.py"
else
  echo "python3 が無いため skill 配線をスキップ"
fi

echo "お疲れ様でした。"
