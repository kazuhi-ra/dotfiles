#!/bin/bash

sudo apt update
sudo apt upgrade

# for xremap
sudo usermod -a -G input $USER
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/99-input.rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# 1password
if [ "$(which op)" = "" ]; then
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg  
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" |
  sudo tee /etc/apt/sources.list.d/1password.list
  sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
  curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
  sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
  sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
fi

# ulauncher
if [ "$(which ulauncher)" = "" ]; then
  sudo add-apt-repository universe -y && sudo add-apt-repository ppa:agornostal/ulauncher -y
fi

# apt install
echo "apt install"
sudo apt update
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/apt_list"

xargs sudo apt install -y <"${SCRIPT_DIR}"

# gnome tweaks
dconf load / < ./.bin/linux/dconf-backup.ini

# zshに
chsh -s "$(which zsh)"

# systemd
systemctl --user daemon-reload
systemctl --user restart xremap
systemctl --user enable xremap

