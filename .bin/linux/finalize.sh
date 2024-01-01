# gnome tweaks
dconf load / < ./.bin/linux/dconf-backup.ini

chsh -s "$(which zsh)"

# systemd
systemctl --user daemon-reload
systemctl --user restart xremap
systemctl --user enable xremap
