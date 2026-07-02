#!/bin/bash

brew bundle --global

echo "delta"
if [ "$(which delta)" = "" ]; then
  cargo install git-delta
fi
