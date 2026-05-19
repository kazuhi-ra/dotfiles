# Homebrew
if [ "$(which brew)" = "brew not found" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# config
export XDG_CONFIG_HOME="$HOME/.config"

# ghcup-env
[ -f "/Users/kazuhi-ra/.ghcup/env" ] && source "/Users/kazuhi-ra/.ghcup/env"

export PATH="$HOME/.rbenv/bin:$PATH"

# zplug
export ZPLUG_HOME=$HOMEBREW_PREFIX/opt/zplug
source $ZPLUG_HOME/init.zsh

source $HOME/.zshrc.common.zsh

export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

export EDITOR=nvim
