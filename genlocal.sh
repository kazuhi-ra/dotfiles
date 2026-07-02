#!/bin/bash
# ローカル版ファイル(git 管理外の *.local)を生成する。
# 既に存在する場合は何もしない(破壊しない)ので、何度実行しても安全。
#
# 使い方:
#   ./genlocal.sh                  # このマシンの規定の拡張ポイントを生成
#   ./genlocal.sh <repo-file>...   # 指定した公開ファイルのローカル版 <file>.local を生成
#
# 例: shared/home/.config/tmux/tmux.conf を追加したあと、マシン固有の
#     上書きを書きたくなったら ./genlocal.sh shared/home/.config/tmux/tmux.conf
set -eu

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

# ローカル版を作っても意味がないもの(.local を読み込む仕組みがない・機械生成など)は、
# 各層のディレクトリ直下の .genlocalignore に列挙する(例: mac/.genlocalignore)。
# 書式: 1 行 1 パス(その層からの相対)、ディレクトリなら配下すべて、# 以降はコメント。
IGNORE_FILE=".genlocalignore"

# $ROOT_DIR からの相対パスに正規化する
rel_path() {
  local abs
  abs="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  echo "${abs#"$ROOT_DIR"/}"
}

is_blacklisted() {
  local rel="$1"
  local layer="${rel%%/*}"
  local ignore_file="$ROOT_DIR/$layer/$IGNORE_FILE"
  [ -f "$ignore_file" ] || return 1

  local line entry
  while IFS= read -r line; do
    line="${line%%#*}"                            # コメントを除去
    line="${line#"${line%%[![:space:]]*}"}"       # 前後の空白を除去
    line="${line%"${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue

    entry="$layer/$line"
    if [ "$rel" = "$entry" ] || [[ "$rel" == "$entry"/* ]]; then
      return 0
    fi
  done <"$ignore_file"
  return 1
}

# 全マシンで必ず存在してほしい拡張ポイント。
# 新しい拡張ポイントを規約に加えたらここに足す。
default_targets() {
  local machine
  machine="$(resolve_machine)"
  echo "$ROOT_DIR/$machine/home/.zshrc.local"     # .zshrc.common.zsh の最後に source される
  echo "$ROOT_DIR/$machine/home/.gitconfig.local" # .gitconfig の [include] から読まれる
}

generate() {
  local target="$1"
  if [ -e "$target" ]; then
    echo "skip (already exists): $target"
    return
  fi

  mkdir -p "$(dirname "$target")"
  case "$target" in
  *.json)
    # コメントを書けないので空のオブジェクトだけ置く
    printf '{}\n' >"$target"
    ;;
  *)
    cat >"$target" <<EOF
# $(basename "$target") — このマシンだけの設定(*.local は git 管理外)
# 公開したくないもの(トークン、仕事用の設定など)はここに書く。
EOF
    ;;
  esac
  echo "created: $target"
}

if [ "$#" -eq 0 ]; then
  while IFS= read -r target; do
    generate "$target"
  done < <(default_targets)
else
  for src in "$@"; do
    case "$src" in
    *.local | *.local.*)
      echo "skip (それ自体がローカル版です): $src"
      continue
      ;;
    esac
    if [ ! -e "$src" ]; then
      echo "skip (公開側のファイルが見つかりません): $src" >&2
      continue
    fi
    if is_blacklisted "$(rel_path "$src")"; then
      echo "skip (ローカル版を作らない規約のファイルです): $src"
      continue
    fi
    generate "${src}.local"
  done
fi
