#!/bin/bash
# 各マシンディレクトリが規約(必須スクリプト)を満たしているか検査する。
# マシンの発見も規約ベース: 「home/ を持つトップレベルディレクトリ(shared を除く)」。
# 新しいマシンを追加したときや、スクリプトをリネームしたときに実行する。
set -u

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

REQUIRED=(init.sh install_packages.sh languages.sh editor.sh)
status=0
found=0

for machine_dir in "$ROOT_DIR"/*/; do
  machine="$(basename "$machine_dir")"
  [ -d "$machine_dir/home" ] || continue
  [ "$machine" = "shared" ] && continue
  found=$((found + 1))

  for f in "${REQUIRED[@]}"; do
    path="$ROOT_DIR/$machine/$f"
    if [ ! -x "$path" ]; then
      echo "NG: $machine/$f がないか、実行権限がありません"
      status=1
    fi
  done
done

if [ "$found" -eq 0 ]; then
  echo "NG: マシンディレクトリが 1 つも見つかりません"
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "OK: すべてのマシン($found 台分)が規約を満たしています"
fi
exit "$status"
