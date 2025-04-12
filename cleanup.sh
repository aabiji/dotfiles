#!/bin/bash

# Cleanup unused packages
pacman -Qdtq | sudo pacman -Rns -

# Cleanup /var/log/journal
sudo journalctl --vacuum-size=50M
