#!/bin/bash

sudo apt update
sudo apt install curl git python3-pip build-essential p7zip-full gocryptfs zsh tmux vim-gtk3 gnome-tweaks
sudo snap install code --classic
sudo snap install obsidian --classic
sudo snap install spotify brave
sudo snap remove firefox

# Clone all repos to the dev/archive folder
cd ~ && mkdir -p dev/archive && cd dev/archive
curl -sS https://webi.sh/gh | sh
~/.local/bin/gh auth login
~/.local/bin/gh repo list aabiji --limit 4000 | while read -r repo _; do
    ~/.local/bin/gh repo clone "$repo" "$repo"
done
mv ~/dev/archive/aabiji/* ~/dev/archive
rm -r ~/dev/archive/aabiji ~/.local/bin ~/.local/opt

# Setup journal and dotfiles
cd ~ && mv dev/archive/journal .
mv ~/dev/archive/dotfiles ~/dev/dotfiles

# Symlink my dotfiles
traverse() {
    local dir="$1"
    for entry in "$dir"/.* "$dir"/*; do
        filename=$(basename "$entry") # Get just the filename
        if [[
            "$filename" == "." ||
            "$filename" == ".." ||
            "$filename" == *.sh ||
            "$filename" == .\*  ||
            "$filename" == ".git" ]]; then
            continue # Skip unwanted entries
        fi

        if [[ -d "$entry" ]]; then
            traverse "$entry"  # Go into the directory
        else
            ln -s "$entry" "/home/aabiji/$filename" # Create the symlink
        fi
    done
}
traverse ~/dev/dotfiles

# Switch to zsh
chsh -s /bin/zsh aabiji

# Update
sudo apt update && sudo apt upgrade -y && sudo snap refresh
