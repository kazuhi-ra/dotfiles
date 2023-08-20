#!/bin/bash

########################## anyenv ##########################

if [ ! "$(which anyenv)" = "" ]; then
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

mkdir -p "$(anyenv root)/plugins"
git clone https://github.com/znz/anyenv-update.git "$(anyenv root)/plugins/anyenv-update"
anyenv update

########################## brewで入れたrustup-init ##########################
if [ "$(which cargo)" = "" ]; then
  rustup-init
fi

########################## haskell ##########################
# if [ "$(which ghc)" = "" ]; then
#   curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
# fi
