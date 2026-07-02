#!/bin/bash
# shared/home → <machine>/home の順に $HOME へ symlink する(後勝ち)
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
      # ディレクトリは実体を作って中身だけ link し、~/.ssh 等で
      # リポジトリ外のファイルと共存できるようにする
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
