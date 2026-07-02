export PATH="$HOME/.anyenv/bin:$PATH"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

source $HOME/.zplug/init.zsh
source $HOME/.zshrc.common.zsh

alias d="docker"
alias ld="lazydocker"
alias r="tmux source-file ~/.config/tmux/tmux.conf && exec $SHELL -l"
alias x="tmux"
alias xx="tmux kill-server"

# anyenv
eval "$(anyenv init -)"

# ghc
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
