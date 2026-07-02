# dotfiles

Mac / Ubuntu デスクトップ / Linux サーバーの設定を 1 つの規約で管理する。

## 構造

```
dotfiles/
├── init.sh            # ①下ごしらえ(link まで)
├── setup.sh           # ②本セットアップ
├── genlocal.sh        # *.local の生成
├── check.sh           # マシン規約の検査
├── lib/               # 内部実装
├── githooks/          # pre-commit(秘密の混入をブロック)
├── shared/
│   ├── home/          # 全マシン共通の $HOME ミラー
│   └── vscode/        # 展開先が特殊なため別枠
├── mac/
│   ├── home/          # マシン固有の $HOME ミラー(shared より優先)
│   └── *.sh           # マシン規約のスクリプト + データ
├── ubuntu-desktop/
└── server/
```

- `$HOME` に link されるのは各層の `home/` の中身だけ。`lib/link.sh` が shared → machine の順に張る(後勝ち)
- マシンディレクトリは「`home/` を持つトップレベルディレクトリ(shared 以外)」で、
  `init.sh` `install_packages.sh` `languages.sh` `editor.sh` を実装する(`./check.sh` で検査)
- マシン判定は `lib/common.sh` のみ。初回の `./init.sh` が `~/.config/dotfiles/machine` に保存し、以後はそれが正

## どこに何を書くか

| 内容 | 置き場 |
|---|---|
| 全マシン共通 | `shared/home/` |
| マシン種別ごと | `<machine>/home/` |
| そのマシンだけ・非公開 | 同じ場所にファイル名 `.local` で置く |

`*.local` は .gitignore と pre-commit フックで git の外に保たれ、link は普通のファイルと同じ扱い。

- `<machine>/home/.zshrc.local` — `.zshrc.common.zsh` の最後に source される
- `<machine>/home/.gitconfig.local` — `.gitconfig` の include で読まれる
- SSH 鍵は `github.local` のように命名する(`.ssh/config` が参照済み)

上記 2 つは `./genlocal.sh` が生成する。任意のファイルは `./genlocal.sh <file>` で隣に
`.local` を作れる(読み込む仕組みは公開側に書くこと)。除外は各層の `.genlocalignore`。

一覧の確認: `git ls-files --others --ignored --exclude-standard | grep '\.local'`

## セットアップ

```sh
# Linux のみ
sudo apt update && sudo apt upgrade && sudo apt install -y git curl zsh

mkdir -p ~/workspace/github.com/kazuhi-ra && git clone https://github.com/kazuhi-ra/dotfiles.git ~/workspace/github.com/kazuhi-ra/dotfiles
cd ~/workspace/github.com/kazuhi-ra/dotfiles && ./init.sh
```

ubuntu-desktop は mozc に `ubuntu-desktop/mozc.txt` を import して再起動。

1Password で SSH を設定(鍵は `<machine>/home/.ssh/github.local`、chmod 600)したら:

```sh
ssh -T git@github.com
./setup.sh
git remote set-url origin git@github.com:kazuhi-ra/dotfiles.git
```

## メモ

- nvim 設定は別リポジトリ([nvim-user-v6](https://github.com/kazuhi-ra/nvim-user-v6))。`lib/nvim.sh` が ghq で取得して link する
- フォントはコミットせず `ubuntu-desktop/fonts.sh` が Release から取得する
- vscode の拡張一覧はマニフェスト。現状で固定し直すには `shared/vscode/install.sh --freeze`
