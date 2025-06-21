#!/bin/bash

# Removes old revisions of snaps
set -eu
LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done

# Cleanup coredumps
sudo systemd-tmpfiles --clean

# Cleanup /var/log/journal
sudo journalctl --vacuum-size=50M

# Remove docker container
sudo docker system prune
