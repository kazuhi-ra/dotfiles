#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$(dirname "${SCRIPT_DIR}")/nvim.sh"

cd vscode || exit
./vscode_install.sh
