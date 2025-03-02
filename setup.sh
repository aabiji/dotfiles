#!/bin/bash

# Install prerequisites
sudo apt install curl wget gpg

curl -fsSL https://bun.sh/install | bash # Install bun
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # Install rust

sudo apt update
sudo apt install git python3-pip build-essential p7zip-full gocryptfs zsh golang-go gnome-tweaks vim-gtk3
sudo snap install code --classic
sudo snap install obsidian --classic
snap install ghostty --classic
sudo snap install spotify docker brave yt-dlp gh
sudo snap remove firefox

# Clone all repos to the dev/archive folder
cd ~ && mkdir -p dev/archive && cd dev/archive
ssh-keygen && gh auth login
gh repo list aabiji --limit 4000 | while read -r repo _; do
    gh repo clone "$repo" "$repo"
done
mv ~/dev/archive/aabiji/* ~/dev/archive
sudo snap remove gh
rm -r ~/dev/archive/aabiji

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
sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo snap refresh
