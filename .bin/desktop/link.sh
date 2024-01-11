#!/bin/bash

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# 処理対象のディレクトリを指定
SCRIPT_DIRS=("$SCRIPT_DIR" "$BASE_DIR/shared")

for dir in "${SCRIPT_DIRS[@]}"; do
  echo "Processing directory: $dir"

  # ディレクトリが存在するかチェック
  if [[ ! -d "$dir" ]]; then
    echo "Directory not found: $dir"
    continue
  fi

  for dotfile in "${dir}"/.??*; do
    if [[ "$dotfile" == "${dir}/.git" ]]; then
      continue
    fi

    if [[ -d "$dotfile" ]]; then
      dotfile_basename=$(basename "$dotfile")
      target_dir="$HOME/$dotfile_basename"

      mkdir -p "$target_dir"

      for file in "$dotfile"/*; do
        ln -fnsv "$file" "$target_dir"
      done
    elif [[ -f "$dotfile" ]]; then
      ln -fnsv "$dotfile" "$HOME"
    fi
  done
done

ln -fnsv "$(dirname "${SCRIPT_DIR}")/.zshrc.common.zsh" "$HOME"
