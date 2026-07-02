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

echo "お疲れ様でした。"
