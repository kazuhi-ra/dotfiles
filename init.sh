#!/bin/bash
# エントリポイント①: マシンの下ごしらえ(再起動前まで)。
# 使い方: ./init.sh [machine]  (省略時は自動判定)
set -eu

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

MACHINE="${1:-$(resolve_machine)}"
if [ ! -d "$ROOT_DIR/$MACHINE/home" ]; then
  echo "不明なマシンです: $MACHINE (home/ を持つトップレベルディレクトリ名を指定してください)" >&2
  exit 1
fi
save_machine "$MACHINE"
echo "マシンプロファイル: $MACHINE"

# 秘密の混入をブロックする pre-commit フックを有効化する
repo_root="$(git -C "$ROOT_DIR" rev-parse --show-toplevel)"
git -C "$repo_root" config core.hooksPath "$ROOT_DIR/githooks"

# ローカル版ファイル(git 管理外の *.local)の規定セットを生成する(既存は触らない)
"$ROOT_DIR/genlocal.sh"

# $HOME へ link する(genlocal の後。生成された *.local も link される)。
# machine init より先に link しておくと、init が systemd unit 等の link 済み設定を参照できる
"$ROOT_DIR/lib/link.sh" "$MACHINE"

"$ROOT_DIR/$MACHINE/init.sh"

echo "次は ssh の設定をしましょう。"
