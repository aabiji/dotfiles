#!/bin/bash

SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$SCHEME" == *"dark"* ]]; then
    echo "󰖙"  # sun icon
else
    echo "󰖔"  # moon icon
fi
