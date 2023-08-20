#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/apt_list"

xargs sudo apt install -y <"${SCRIPT_DIR}"

if [ "$(which starship)" = "" ]; then
  curl -sS https://starship.rs/install.sh | sh
fi

if [ "$(which ghq)" = "" ]; then
  go install github.com/x-motemen/ghq@latest
fi

if [ "$(which zplug)" = "" ]; then
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | sudo zsh
fi
