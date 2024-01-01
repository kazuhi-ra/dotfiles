# dotfiles

## 手順

apt更新

```sh
sudo apt update && sudo apt upgrade
```

clone

```sh
sudo apt install git curl
mkdir -p ~/workspace/github.com/kazuhi-ra && git clone https://github.com/kazuhi-ra/dotfiles.git ~/workspace/github.com/kazuhi-ra/dotfiles
```

セットアップコマンド実行

```bash
cd workspace/github.com/kazuhi-ra/dotfiles
.bin/setup.sh
```

mozcに設定ファイルをimport

`.bin/linux/mozc.txt`

https -> ssh

```sh
git remote set-url origin git@github.com:kazuhi-ra/dotfiles.git
```

## 仕事マシン向けメモ

.zshrcについて、特別な設定が必要な場合はそのマシンの`.user.sh`に書きましょう。
