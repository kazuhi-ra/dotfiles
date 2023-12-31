#!/bin/bash

if [ "$(uname)" = "Darwin" ]; then
  HOST_NAME="mac"
elif [ "$(uname)" = "Linux" ]; then
  HOST_NAME="linux"
fi

eval ".bin/${HOST_NAME}/init.sh"

eval ".bin/${HOST_NAME}/link.sh"

eval ".bin/${HOST_NAME}/install_packages.sh"

eval ".bin/${HOST_NAME}/languages.sh"

eval ".bin/${HOST_NAME}/editor.sh"

eval ".bin/${HOST_NAME}/finalize.sh"

echo "お疲れ様でした。"
