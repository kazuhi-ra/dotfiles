#!/bin/bash

if [ "$(uname)" = "Darwin" ]; then
  DIR_NAME="mac"
elif [ "$(uname)" = "Linux" ]; then
  if [ "$(hostname)" = "zunda" ] || [ "$(hostname)" = "himari" ]; then
    DIR_NAME="desktop"
  else
    DIR_NAME="workstation"
  fi
fi

eval ".bin/${DIR_NAME}/init.sh"
eval ".bin/${DIR_NAME}/link.sh"

echo "次はsshの設定をしましょう。"
