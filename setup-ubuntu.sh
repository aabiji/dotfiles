#!/bin/bash

# Update and install base tools
sudo apt update && sudo apt install -y \
    git build-essential curl unzip p7zip-full fish gdb tmux ninja-build \
    openssh-client cmake alsa-utils printer-driver-all xclip neovim npm \
    fonts-iosevka alacritty cloc libfuse2 software-properties-common

sudo snap install brave spotify gh
sudo snap install obsidian --classic
sudo snap install code --classic

# Setup GitHub auth and clone repos
cd ~ && mkdir -p ~/dev/archive && cd ~/dev/archive
gh auth login
gh repo list aabiji --limit 4000 | while read -r repo _; do
    gh repo clone "$repo" "$repo"
done

mv ~/dev/archive/aabiji/* ~/dev/archive
rm -r ~/dev/archive/aabiji

# Move journal and dotfiles
cd ~ && mv dev/archive/journal .
mv ~/dev/archive/dotfiles ~/dev/dotfiles

# Symlink dotfiles
traverse() {
    local dir="$1"
    local base="$2"

    shopt -s dotglob
    for entry in "$dir"/* "$dir"/.*; do
        filename=$(basename "$entry")
        if [[ ! -e "$entry" || "$filename" == "." || "$filename" == ".." || "$filename" == *.sh || "$filename" == ".git" ]]; then
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
traverse "$HOME/dev/dotfiles/files" "$HOME/dev/dotfiles/files"

# Change default shell to fish
chsh -s /usr/bin/fish aabiji

# Final system update
sudo apt update && sudo apt upgrade -y
