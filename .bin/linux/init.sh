#!/bin/bash

sudo apt update
sudo apt upgrade

chsh -s "$(which zsh)"
