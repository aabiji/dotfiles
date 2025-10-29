#!/bin/bash

SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$SCHEME" == *"dark"* ]]; then
    # Switch to light
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
else
    # Switch to dark
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-dark'
fi

# Reload waybar
pkill -SIGUSR2 waybar
