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

# ghq
function peco-ghq-look() {
  local project dir repository session current_session
  project=$(ghq list -p | peco --prompt='Project >')

  if [[ $project == "" ]]; then
    return 1
  else
    dir=$project
  fi

  if [[ ! -z ${TMUX} ]]; then
    repository=${dir##*/}
    session=${repository//./-}
    current_session=$(tmux list-sessions | grep 'attached' | cut -d":" -f1)

    if [[ $current_session =~ ^[0-9]+$ ]]; then
      cd $dir
      tmux rename-session $session
    else
      tmux list-sessions | cut -d":" -f1 | grep -e "^$session\$" > /dev/null
      if [[ $? != 0 ]]; then
        tmux new-session -d -c $dir -s $session
      fi
      tmux switch-client -t $session
    fi
    tmux send-keys -t $session 'nvim' Enter
  else
    cd $dir
  fi
}

zle -N peco-ghq-look
bindkey '^G' peco-ghq-look

# anyenv
eval "$(anyenv init -)"

# ghc
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"
