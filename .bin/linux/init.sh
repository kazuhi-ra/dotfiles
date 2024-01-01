#!/bin/bash

sudo apt update
sudo apt upgrade

# for xremap
sudo usermod -a -G input $USER
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/99-input.rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# apt install
echo "apt install"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)/apt_list"

xargs sudo apt install -y <"${SCRIPT_DIR}"

