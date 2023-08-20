#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/apt_list"

xargs sudo apt install -y <"${SCRIPT_DIR}"

if [ "$(which starship)" = "" ]; then
  curl -sS https://starship.rs/install.sh | sh
fi

if [ "$(which ghq)" = "" ]; then
  go install github.com/x-motemen/ghq@latest
fi

if [ "$(which lazygit)" = "" ]; then
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
fi

if [ "$(which anyenv)" = "" ]; then
  git clone https://github.com/anyenv/anyenv ~/.anyenv 
fi

if [ "$(which rustup)" = "" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if [ "$(which delta)" = "" ]; then
  cargo install git-delta
fi

if [ "$ZPLUG_HOME" = "" ]; then
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi
