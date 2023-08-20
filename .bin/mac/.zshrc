# Homebrew
if [ "$(which brew)" = "brew not found" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ghcup-env
[ -f "/Users/kazuhi-ra/.ghcup/env" ] && source "/Users/kazuhi-ra/.ghcup/env"

# ssh
if [ -f ~/.ssh-agent ]; then
  . ~/.ssh-agent
fi
if [ -z "$SSH_AGENT_PID" ] || ! kill -0 $SSH_AGENT_PID; then
  ssh-agent >~/.ssh-agent
  . ~/.ssh-agent
fi
ssh-add -l &>/dev/null || ssh-add

# PUPPETEER M1 bug
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# zplug
export ZPLUG_HOME=$HOMEBREW_PREFIX/opt/zplug
source $ZPLUG_HOME/init.zsh

source $HOME/.zshrc.common.zsh
