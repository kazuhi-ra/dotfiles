autoload -Uz compinit && compinit
autoload -Uz colors && colors

HISTSIZE=100000
SAVEHIST=100000
setopt append_history
setopt share_history
setopt hist_ignore_all_dups

bindkey -e

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# cdr
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi

# peco history
function peco-cdr () {
  local selected_dir="$(cdr -l | sed 's/^[0-9]\+ \+//' | peco --prompt="cdr >" --query "$LBUFFER")"
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir} && nvim"
    zle accept-line
  fi
}

zle -N peco-cdr
bindkey '^r' peco-cdr

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

alias l="ls -alF -G"
alias t="tree -CL 2 -I node_modules"
alias tt="tree -aCL 2 -I node_modules"
alias reload="exec $SHELL -l"
alias v="nvim"
alias vi="nvim"
alias f="fg"
alias ..="cd .."
alias ...="cd ../.."

function chpwd() {
  tree -CL 1
}

# ssh
if [ -f ~/.ssh-agent ]; then
  . ~/.ssh-agent
fi
if [ -z "$SSH_AGENT_PID" ] || ! kill -0 $SSH_AGENT_PID; then
  ssh-agent >~/.ssh-agent
  . ~/.ssh-agent
fi
ssh-add -l &>/dev/null || ssh-add


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
zplug load

source $HOME/.cargo/env
if [ -f $HOME/.user.zsh ]; then
  source $HOME/.user.zsh
fi
