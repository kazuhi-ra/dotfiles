# gnome tweaks
dconf load / < dconf-backup.ini

# systemd
systemctl --user daemon-reload
systemctl --user restart xremap
systemctl --user enable xremap
