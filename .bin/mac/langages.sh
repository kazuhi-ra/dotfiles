#!/bin/bash

########################## anyenv ##########################

if [ "$(which anyenv)" = "" ]; then
  echo "anyenvを初期化します"
  anyenv install --init
fi

if [ "$(which nodenv)" = "" ]; then
  echo "nodenvをインストールします"
  anyenv install nodenv
fi

if [ "$(which rbenv)" = "" ]; then
  echo "rbenvをインストールします"
  anyenv install rbenv
fi

if [ "$(which goenv)" = "" ]; then
  echo "goenvをインストールします"
  anyenv install goenv
fi

mkdir -p "$(anyenv root)/plugins"
git clone https://github.com/znz/anyenv-update.git "$(anyenv root)/plugins/anyenv-update" 2>/dev/null || true
eval "$(anyenv init -)"
anyenv update

if [ "$(which node)" = "" ]; then
	nodenv install 20.10.0
	nodenv global 20.10.0
fi

if [ "$(which ruby)" = "" ]; then
	rbenv install 3.3.6
	rbenv global 3.3.6
fi

if [ "$(which go)" = "" ]; then
	goenv install 1.24.0
	goenv global 1.24.0
fi

########################## brewで入れたrustup-init ##########################
if [ "$(which cargo)" = "" ]; then
  rustup-init
fi

########################## haskell ##########################
