#!/bin/bash

########################## anyenv ##########################

source ~/.zshrc
anyenv install --init

if [ "$(which nodenv)" = "" ]; then
  echo "nodenvをインストールします"
  anyenv install nodenv
fi

if [ "$(which rbenv)" = "" ]; then
  echo "rbenvをインストールします"
  anyenv install rbenv
fi

mkdir -p "$(anyenv root)/plugins"
git clone https://github.com/znz/anyenv-update.git "$(anyenv root)/plugins/anyenv-update"
anyenv update

######################### haskell ##########################
if [ "$(which ghc)" = "" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
fi


########################## install lang ##########################

if [ "$(which node)" = "" ]; then
  nodenv install 20.10.0
  nodenv global 20.10.0
fi

if [ "$(which ruby)" = "" ]; then
  rbenv install 3.3.0
  rbenv global 3.3.0
fi
