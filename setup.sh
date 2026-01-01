#!/bin/bash

sudo apt install -y git curl wget p7zip fish ninja-build cmake ripgrep nodejs wl-clipboard gh build-essential

# brave
curl -fsS https://dl.brave.com/install.sh | sh

sudo snap install obsidian --classic
sudo snap install spotify

# neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

# ghostty
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

# Setup GitHub auth and clone repos
mkdir -p dev/archive
cd ~/dev/archive
gh auth login
gh repo list aabiji --limit 1000 | awk '{print $1; }' | xargs -L1 gh repo clone

# Move journal and dotfiles
cd ~
if [ -d ~/dev/archive/journal ]; then
    mv ~/dev/archive/journal .
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
