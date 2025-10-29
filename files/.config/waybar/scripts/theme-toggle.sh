#!/bin/bash

SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$SCHEME" == *"dark"* ]]; then
    # Switch to light
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
    
    # Update Hyprland colors
    hyprctl keyword general:col.active_border "rgba(333333ee)"
    hyprctl keyword general:col.inactive_border "rgba(ccccccaa)"
else
    # Switch to dark
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-dark'
    
    # Update Hyprland colors
    hyprctl keyword general:col.active_border "rgba(ffffffee)"
    hyprctl keyword general:col.inactive_border "rgba(595959aa)"
fi

# Reload waybar
pkill -SIGUSR2 waybar
