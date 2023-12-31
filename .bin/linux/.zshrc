export PATH="$HOME/.anyenv/bin:$PATH"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

source $HOME/.zplug/init.zsh

source $HOME/.zshrc.common.zsh

bindkey "^[OA" history-beginning-search-backward-end
bindkey "^[OB" history-beginning-search-forward-end

xset r rate 225 30

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
