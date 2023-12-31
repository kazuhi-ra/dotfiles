#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for dotfile in "${SCRIPT_DIR}"/.??*; do
  if [[ "$dotfile" == "${SCRIPT_DIR}/.git" ]]; then
    continue
  fi

  if [[ -d "$dotfile" ]]; then
    # $dotfileがディレクトリの場合の処理
    dotfile_basename=$(basename "$dotfile")
    target_dir="$HOME/$dotfile_basename"

    # 同名のディレクトリがなければ作成
    mkdir -p "$target_dir"

    # ディレクトリ内のファイルに対してシンボリックリンクを作成
    for file in "$dotfile"/*; do
      ln -fnsv "$file" "$target_dir"
    done
  elif [[ -f "$dotfile" ]]; then
    # $dotfileがファイルの場合の処理
    ln -fnsv "$dotfile" "$HOME"
  fi
done

ln -fnsv "$(dirname "${SCRIPT_DIR}")/.zshrc.common.zsh" "$HOME"
