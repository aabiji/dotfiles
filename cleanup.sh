#!/bin/bash

# Cleanup unused packages
sudo pacman -Qdtq | sudo pacman -Rns -

sudo pacman -Scc

# Cleanup coredumps
sudo systemd-tmpfiles --clean

# Cleanup /var/log/journal
sudo journalctl --vacuum-size=50M

# Remove docker container
sudo docker system prune
