#!/bin/bash

sudo apt update
sudo apt upgrade

if [ "$(which docker)" = "" ]; then
  # Add Docker's official GPG key:
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  # install docker packages
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # add user docker group
  sudo usermod -aG docker ${USER}
fi

# apt install
echo "apt install"
sudo apt update
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/apt_list"

xargs sudo apt install -y <"${SCRIPT_DIR}"

# zshに
chsh -s "$(which zsh)"

