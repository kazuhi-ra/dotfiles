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
alias r="herdr server reload-config && exec $SHELL -l"
alias x="herdr"
alias xx="herdr server stop"

# anyenv
eval "$(anyenv init -)"

# ghc
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
