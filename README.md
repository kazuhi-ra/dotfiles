# dotfiles

Mac / Ubuntu デスクトップ / Linux サーバーの設定を、1 つの規約で管理する。

## 構造

トップレベルは「層」(shared + 各マシン)と「道具」(エントリポイントと lib/)だけ。
マシンのことを知りたければそのマシンのディレクトリへ、仕組みを知りたければルートへ。

```
dotfiles/
├── README.md
├── init.sh                # エントリポイント①: 下ごしらえ(link まで)
├── setup.sh               # エントリポイント②: 本セットアップ
├── genlocal.sh            # *.local ファイルの生成(git 管理外の設定の雛形)
├── check.sh               # マシン規約の検査
├── lib/                   # 内部実装(マシン判定・link・nvim)
├── githooks/              # 秘密の混入をブロックする pre-commit
│
├── shared/                # ここから下が「層」
│   ├── home/              #   全マシン共通の $HOME ミラー(tmux, wezterm ...)
│   └── vscode/            #   link 対象外の共有物(VSCode は展開先が特殊なため)
├── mac/
│   ├── home/              #   Mac の $HOME ミラー(.zshrc, .Brewfile, karabiner ...)
│   └── *.sh               #   マシン規約のスクリプト + 補助スクリプト
├── ubuntu-desktop/
│   ├── home/
│   └── *.sh, apt_list, dconf-backup.ini, mozc.txt   # データも同居できる
└── server/
    ├── home/
    └── *.sh, apt_list
```

ルールは 2 つ:

1. **`$HOME` に link されるのは、各層の `home/` サブディレクトリの中身だけ**。
   `lib/link.sh` が `shared/home` → `<machine>/home` の順に張る(後勝ちなので
   マシン固有が共通を上書きできる)
2. **マシンディレクトリ = 「home/ を持つトップレベルディレクトリ(shared を除く)」**。
   下記の 4 スクリプトを実装する(`./check.sh` で検査できる)

| ファイル | 役割 | 呼び出し元 |
|---|---|---|
| `init.sh` | OS の初期化(apt, brew の導入など) | `./init.sh` |
| `install_packages.sh` | パッケージ導入 | `./setup.sh` |
| `languages.sh` | 言語環境(anyenv 等) | `./setup.sh` |
| `editor.sh` | エディタ(nvim / vscode) | `./setup.sh` |

エントリポイントはマシン名を解決したあと同名ファイルを呼ぶだけなので、
**マシンの追加 = トップレベルにディレクトリを 1 つ作って規約を実装するだけ**。

マシン判定は `lib/common.sh` にのみ書く。初回の `./init.sh` 実行時に
`~/.config/dotfiles/machine` へ保存され、以後はそれが正となる
(`./init.sh mac` のように明示指定も可能)。

## どこに何を書くか

| 書きたいもの | 置き場 | 例 |
|---|---|---|
| 全マシン共通の公開設定 | `shared/home/` | tmux, wezterm, `.zshrc.common.zsh` |
| マシン種別ごとの公開設定 | `<machine>/home/` | `.Brewfile`, karabiner, xremap |
| **このマシンだけの設定・秘密** | 公開ファイルの隣に **`.local`** を付けて置く | `.zshrc.local`, `.gitconfig.local`, `.ssh/github.local` |

迷ったらこれだけ: **公開したくないものは、ファイル名に `.local` を含めて、公開ファイルと同じ場所に置く。**
`*.local` は .gitignore で git 管理外になり、link.sh は普通のファイルと同じように `$HOME` へ link する。

規定の拡張ポイント(`./genlocal.sh` が生成、既存なら触らない):

- `<machine>/home/.zshrc.local` → `~/.zshrc.local` に link され、`.zshrc.common.zsh` の最後に source される
- `<machine>/home/.gitconfig.local` → `~/.gitconfig.local` に link され、`.gitconfig` の `[include]` から読まれる

任意のファイルにローカル版を追加したいときは:

```sh
./genlocal.sh shared/home/.config/tmux/tmux.conf   # → tmux.conf.local を生成
```

生成されるのはファイルだけなので、公開側の設定から読み込む仕組み(source / include /
ツールのオプション)は必要に応じて公開側に書くこと。SSH の秘密鍵のような
「名前を自分で決められるファイル」は、最初から `github.local` のように命名すれば
そのまま規約に乗る(`.ssh/config` は `~/.ssh/github.local` を指している)。
ローカル版を作っても意味がないもの(GUI 生成の設定など)は、各層のディレクトリ直下の
`.genlocalignore` に理由コメントつきで列挙してある(例: `mac/.genlocalignore`)。

### 秘密が公開されない仕組み

1. **規約**: git 管理外のものはファイル名に `.local`。名前を見れば公開可否が分かる
2. **.gitignore**: `*.local` と `*.local.*` の 2 行のみ
3. **pre-commit フック**: `.local` を含むパスや秘密鍵らしき内容が staged されたら
   コミットを拒否する(`githooks/`、init.sh が有効化)

`~/.ssh/known_hosts` のような「名前を変えられない生成物」はリポジトリで管理しない。
また、より強くしたければ SSH 鍵は 1Password SSH agent に寄せてファイル自体をなくすのも手。

`.local` ファイルの一覧(バックアップしたいときなど)は:

```sh
git ls-files --others --ignored --exclude-standard | grep '\.local'
```

## セットアップ手順

必要なパッケージを入れる(Linux のみ):

```sh
sudo apt update && sudo apt upgrade && sudo apt install -y git curl zsh
```

clone して下ごしらえ:

```sh
mkdir -p ~/workspace/github.com/kazuhi-ra && git clone https://github.com/kazuhi-ra/dotfiles.git ~/workspace/github.com/kazuhi-ra/dotfiles
cd ~/workspace/github.com/kazuhi-ra/dotfiles && ./init.sh
```

(ubuntu-desktop のみ)mozc に `ubuntu-desktop/mozc.txt` を import し、再起動:

```sh
sudo reboot
```

1password で ssh の設定(鍵は `<machine>/home/.ssh/github.local` に置き `chmod 600`)をして確認:

```sh
ssh -T git@github.com
```

本セットアップ:

```sh
./setup.sh
```

remote を https から ssh に:

```sh
git remote set-url origin git@github.com:kazuhi-ra/dotfiles.git
```

## 設計メモ

- **link の仕組み**: ディレクトリは 1 階層だけ実体を作って中身を link するため、
  `~/.ssh` や `~/.config` ではリポジトリ外の実ファイルと共存できる。
- **symlink 方式の利点**: `$HOME` 側で設定を編集すると即 `git diff` に現れる。
  試行錯誤してそのままコミットできる。
- **nvim**: 設定は別リポジトリ([nvim-user-v6](https://github.com/kazuhi-ra/nvim-user-v6))。
  `lib/nvim.sh` が ghq で取得して `~/.config/nvim` に link する。
- **フォント**: .ttf はコミットせず `ubuntu-desktop/fonts.sh` が
  GitHub Release から取得する。
