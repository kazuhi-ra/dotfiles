#!/bin/bash
# shared/home と <machine>/home の 2 層を $HOME に symlink する。
# あとから link した層が勝つ (ln -f) ので、shared → machine の順に処理し、
# マシン固有の設定が共通設定を上書きできるようにする。
# git 管理外の *.local ファイルも、リポジトリ内にあれば同じように link される。
set -eu

MACHINE="${1:?usage: link.sh <machine>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

link_layer() {
  local layer="$1"
  echo "Linking layer: $layer"

  local dotfile base child
  for dotfile in "$layer"/.??*; do
    [ -e "$dotfile" ] || continue
    base="$(basename "$dotfile")"

    if [ -d "$dotfile" ]; then
      # ディレクトリは 1 階層だけ実体を作り、中身を symlink する
      # (~/.ssh や ~/.config に、リポジトリ外の実ファイルと共存させるため)
      mkdir -p "$HOME/$base"
      for child in "$dotfile"/*; do
        ln -fnsv "$child" "$HOME/$base/$(basename "$child")"
      done
    else
      ln -fnsv "$dotfile" "$HOME/$base"
    fi
  done
}

link_layer "$ROOT_DIR/shared/home"
link_layer "$ROOT_DIR/$MACHINE/home"
