# dotfiles

## 手順

clone

```sh
mkdir -p ~/workspace/github.com/kazuhi-ra && git clone https://github.com/kazuhi-ra/dotfiles.git ~/workspace/github.com/kazuhi-ra/dotfiles
```

セットアップコマンド実行

```bash
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
