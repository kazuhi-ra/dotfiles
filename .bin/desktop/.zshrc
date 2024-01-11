export PATH="$HOME/.anyenv/bin:$PATH"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

source $HOME/.zplug/init.zsh
source $HOME/.zshrc.common.zsh

alias r="exec $SHELL -l"

# ghq
function peco-ghq-look() {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir} && nvim"
    zle accept-line
  fi
  zle clear-screen
}

zle -N peco-ghq-look
bindkey '^G' peco-ghq-look


xset r rate 225 30
