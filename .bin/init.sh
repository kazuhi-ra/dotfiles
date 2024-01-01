#!/bin/bash

if [ "$(uname)" = "Darwin" ]; then
  HOST_NAME="mac"
elif [ "$(uname)" = "Linux" ]; then
  HOST_NAME="linux"
fi

eval ".bin/${HOST_NAME}/init.sh"

echo "次はsshの設定をしましょう。"
