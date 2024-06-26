#!/bin/bash

echo "starship"
if [ "$(which starship)" = "" ]; then
	curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

echo "ghq"
if [ "$(which ghq)" = "" ]; then
	go install github.com/x-motemen/ghq@latest
fi

echo "lazydocker"
if [ "$(which lazydocker)" = "" ]; then
	go install github.com/jesseduffield/lazydocker@v0.23.0
fi

echo "docker"
if [ "$(which docker)" = "" ]; then
	dockerd-rootless-setuptool.sh install
fi

echo "lazygit"
if [ "$(which lazygit)" = "" ]; then
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit /usr/local/bin
fi

echo "wezterm"
if [ "$(which wezterm)" = "" ]; then
	curl -LO https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22.Ubuntu22.04.deb
	sudo apt install -y ./wezterm-20240203-110809-5046fc22.Ubuntu22.04.deb
fi

echo "tmux"
if [ "$(which tmux)" = "" ]; then
	ghq get -shallow git@github.com:tmux/tmux.git
	cd "$(ghq list --full-path | grep --color=never -E tmux/tmux)" || exit
	cd tmux
	sh autogen.sh
	./configure --enable-sixel --prefix=/usr/local && make
	sudo make install
fi

echo "anyenv"
if [ "$(which anyenv)" = "" ]; then
	git clone https://github.com/anyenv/anyenv ~/.anyenv
	cd ~/.anyenv || exit
fi

echo "rustup"
if [ "$(which rustup)" = "" ]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

echo "delta"
if [ "$(which delta)" = "" ]; then
	cargo install git-delta
fi

echo "xremap"
if [ "$(which xremap)" = "" ]; then
	cargo install xremap --features x11
fi

echo "ZPLUG"
if [ "$ZPLUG_HOME" = "" ]; then
	curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi
