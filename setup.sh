#!/bin/bash

sudo dnf install -y git curl wget p7zip-full fish ninja-build cmake ripgrep wl-clipboard gh build-essential make flatpak
sudo snap remove firefox

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.spotify.Client
flatpak install flathub md.obsidian.Obsidian

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
curl -fsS https://dl.brave.com/install.sh | sh

sudo apt-get install wget gpg &&
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg &&
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg &&
rm -f microsoft.gpg
sudo apt install apt-transport-https &&
sudo apt update && sudo apt install code # or code-insiders

# Setup GitHub auth and clone repos
sudo snap install gh
mkdir -p dev/archive
cd ~/dev/archive
gh auth login
gh repo list aabiji --limit 1000 | awk '{print $1; }' | xargs -L1 gh repo clone
sudo snap remove gh

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
