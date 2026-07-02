export PATH="$HOME/.anyenv/bin:$PATH"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

source $HOME/.zplug/init.zsh
source $HOME/.zshrc.common.zsh

alias r="exec $SHELL -l"

function discord_updater() {
  wget "https://discord.com/api/download/stable?platform=linux&format=deb" -O /tmp/discord-update.deb
  sudo apt install -y /tmp/discord-update.deb
}

function c() {
  echo -n "$*" | xsel --clipboard --input
}

# anyenv
eval "$(anyenv init -)"

# ghc
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# for docker rootless mode
export PATH=/home/kazuhira/bin:$PATH
export DOCKER_HOST=unix:///run/user/1000/docker.sock

xset r rate 225 30
