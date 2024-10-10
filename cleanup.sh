#!/bin/bash

# Cleanup unused packages
sudo apt autoremove -y
sudo apt clean

# Cleanup /var/log/journal
sudo journalctl --vacuum-size=50M

# Remove old snap revisions
set -eu
LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done
