#!/bin/bash

sudo apt install git curl wget p7zip-full fish ninja-build cmake ripgrep gh build-essential make vim -y
sudo apt purge gh papers -y

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

sudo snap install obsidian --classic
sudo snap install nvim --classic
sudo snap install spotify
sudo snap remove firefox

# Setup GitHub auth and clone repos
cd ~ && mkdir -p ~/dev/archive && cd ~/dev/archive
gh auth login
gh repo list aabiji --limit 1000 | awk '{print $1; }' | xargs -L1 gh repo clone

# Move journal and dotfiles
cd ~
if [ -d ~/dev/archive/journal ]; then
    mkdir -p ~/journal/private ~/journal/public
    mv ~/dev/archive/journal/.* ~/dev/archive/journal/* ~/journal/private
    rm ~/dev/archive/journal
fi

if [ -d ~/dev/archive/dotfiles ]; then
    mv ~/dev/archive/dotfiles ~/dev/dotfiles
fi

# Symlink dotfiles
traverse() {
    local dir="$1"
    local base="$2"
    shopt -s dotglob
    for entry in "$dir"/* "$dir"/.*; do
        filename=$(basename "$entry")
        if [[ ! -e "$entry" || "$filename" == "." || "$filename" == ".." || "$filename" == ".git" ]]; then
            continue
        fi
        relative_path="${entry#$base/}"
        target="$HOME/$relative_path"
        if [[ -d "$entry" ]]; then
            mkdir -p "$target"
            traverse "$entry" "$base"
        else
            ln -sf "$entry" "$target"
        fi
    done
    shopt -u dotglob
}

if [ -d "$HOME/dev/dotfiles/files" ]; then
    traverse "$HOME/dev/dotfiles/files" "$HOME/dev/dotfiles/files"
fi

# Change default shell to fish
chsh -s /usr/bin/fish
