#!/bin/bash

# fetch
NVIM_REPO="neovim/neovim"
ghq get "git@github.com:${NVIM_REPO}.git"

USER_REPO="kazuhi-ra/nvim-user-v4"
ghq get "git@github.com:${USER_REPO}.git"

# nvimをbuild
if [ "$(which nvim)" = "" ]; then
	cd "$(ghq list --full-path | grep --color=never -E "${NVIM_REPO}")" || exit
	make CMAKE_BUILD_TYPE=RelWithDebInfo
	sudo make install
fi

# AstroNvimを.config/nvimにlink
if [ ! -d ~/.config/nvim ]; then
	USER_REPO_PATH="$(ghq list --full-path | grep --color=never -E "${USER_REPO}")"
	ln -fnsv "$USER_REPO_PATH" "${HOME}/.config/nvim"
fi
