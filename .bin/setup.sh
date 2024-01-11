#!/bin/bash

if [ "$(uname)" = "Darwin" ]; then
  DIR_NAME="mac"
elif [ "$(uname)" = "Linux" ]; then
  if [ "$(hostname)" = "zunda" ]; then
    DIR_NAME="desktop"
  else
    DIR_NAME="workstation"
  fi
fi

eval ".bin/${DIR_NAME}/install_packages.sh"

eval ".bin/${DIR_NAME}/languages.sh"

eval ".bin/${DIR_NAME}/editor.sh"

echo "お疲れ様でした。"
