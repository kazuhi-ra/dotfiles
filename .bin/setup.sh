#!/bin/bash

HOST_NAME=$(hostname -s) # mac | zunda

eval ".bin/${HOST_NAME}/init.sh"

eval ".bin/${HOST_NAME}/link.sh"

eval ".bin/${HOST_NAME}/install_packages.sh"

eval ".bin/${HOST_NAME}/langages.sh"

eval ".bin/${HOST_NAME}/editor.sh"

eval ".bin/${HOST_NAME}/finalize.sh"

echo "お疲れ様でした。"
