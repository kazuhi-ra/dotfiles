#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for dotfile in "${SCRIPT_DIR}"/.??*; do
  [[ "$dotfile" == "${SCRIPT_DIR}/.git" ]] && continue

  ln -fnsv "$dotfile" "$HOME"
done

ln -fnsv "$(dirname "${SCRIPT_DIR}")/.zshrc.common.zsh" "$HOME"
