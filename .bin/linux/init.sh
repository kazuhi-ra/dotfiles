#!/bin/bash

sudo apt update
sudo apt upgrade

chsh -s "$(which zsh)"

# for xremap
sudo usermod -a -G input $USER
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/99-input.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
