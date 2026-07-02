#!/bin/bash

if [ "$(uname)" != "Darwin" ]; then
  echo "macOSではありません"
  exit 1
else
  echo "macOSの初期設定を開始します"
fi

echo "Mac本体の設定を好みにします"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
eval "$SCRIPT_DIR/mac_settings.sh"

echo "Xcodeをインストールします"
xcode-select --install

echo "Homebrewをインストールします"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ "$(uname -m)" = "arm64" ]; then
  echo "Rosettaをインストールします"
  softwareupdate --install-rosetta --agree-to-license
fi
