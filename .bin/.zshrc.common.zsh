autoload -Uz compinit && compinit
autoload -Uz colors && colors

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$HOME/.zsh_history
setopt append_history
setopt share_history
setopt hist_ignore_all_dups

bindkey -e

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

alias b="batcat"
alias t="tree -ACL 2 -I node_modules"
alias tt="tree -aACL 2 -I node_modules"
alias e="exit"
alias f="fg"
alias d="docker"
alias g="grep"
alias gg="git grep"
alias l="less"
alias ld="lazydocker"
alias ll="ls -alF -G"
alias r="tmux source-file ~/.config/tmux/tmux.conf && exec $SHELL -l"
alias v="nvim"
alias vi="nvim"
alias x="tmux"
alias xx="tmux kill-server"
alias ..="cd .."
alias ...="cd ../.."

function chpwd() {
  tree -ACL 1
}

# when enter
function do_enter() {
  zle accept-line
  if [ -z "$BUFFER" ]; then
    tree -ACL 1
  fi
}

zle -N do_enter
bindkey '^m' do_enter
bindkey '^j' do_enter

# anyenv
eval "$(anyenv init -)"


eval "$(starship init zsh)"

zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
zplug "zsh-users/zsh-history-substring-search"
bindkey '^[OA' history-substring-search-up
bindkey '^P' history-substring-search-up
bindkey '^[OB' history-substring-search-down
bindkey '^N' history-substring-search-down

zplug load

source $HOME/.cargo/env
if [ -f $HOME/.user.zsh ]; then
  source $HOME/.user.zsh
fi
