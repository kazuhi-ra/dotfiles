# dotfiles

## 手順

必要なパッケージを入れる

```sh
sudo apt update && sudo apt upgrade && sudo apt install -y git curl
```

clone

```sh
mkdir -p ~/workspace/github.com/kazuhi-ra && git clone https://github.com/kazuhi-ra/dotfiles.git ~/workspace/github.com/kazuhi-ra/dotfiles
```

下ごしらえ

```bash
cd ~/workspace/github.com/kazuhi-ra/dotfiles && .bin/init.sh
```

1passwordでsshの設定 & ↓で確認

```bash
ssh -T git@github.com
```

mozcに設定ファイルをimport

`.bin/linux/mozc.txt`

https -> ssh

```sh
git remote set-url origin git@github.com:kazuhi-ra/dotfiles.git
```

セットアップコマンド実行

```bash
.bin/setup.sh
```

## 仕事マシン向けメモ

.zshrcについて、特別な設定が必要な場合はそのマシンの`.user.sh`に書きましょう。
