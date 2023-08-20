# Homebrew
if [ "$(which brew)" = "brew not found" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ghcup-env
[ -f "/Users/kazuhi-ra/.ghcup/env" ] && source "/Users/kazuhi-ra/.ghcup/env"

alias zunda="ssh zunda"

# PUPPETEER M1 bug
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# zplug
export ZPLUG_HOME=$HOMEBREW_PREFIX/opt/zplug
source $ZPLUG_HOME/init.zsh

source $HOME/.zshrc.common.zsh

bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end
