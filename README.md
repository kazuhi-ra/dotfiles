# dotfiles

## 手順

必要なパッケージを入れる

```sh
sudo apt update && sudo apt upgrade && sudo apt install -y git curl zsh
```

clone

```sh
mkdir -p ~/workspace/github.com/kazuhi-ra && git clone https://github.com/kazuhi-ra/dotfiles.git ~/workspace/github.com/kazuhi-ra/dotfiles
```

下ごしらえ

```sh
cd ~/workspace/github.com/kazuhi-ra/dotfiles && .bin/init.sh
```

mozcに設定ファイルをimport

`.bin/linux/mozc.txt`

いったん再起動

```sh
sudo reboot
```

1passwordでsshの設定 & ↓で確認(手動でzshに切り替える必要があるかも)

```sh
ssh -T git@github.com
```

セットアップコマンド実行

```sh
.bin/setup.sh
```

https -> ssh

```sh
git remote set-url origin git@github.com:kazuhi-ra/dotfiles.git
```

## 仕事マシン向けメモ

.zshrcについて、特別な設定が必要な場合はそのマシンの`.user.sh`に書きましょう。
