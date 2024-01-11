autoload -Uz compinit && compinit
autoload -Uz colors && colors

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=$HOME/.zsh_history
setopt append_history
setopt share_history
setopt hist_ignore_all_dups

bindkey -e

alias b="batcat"
alias t="tree -ACL 2 -I node_modules"
alias tt="tree -aACL 2 -I node_modules"
alias f="fg"
alias g="grep"
alias ll="ls -alF -G"
alias v="nvim"
alias vi="nvim"
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
