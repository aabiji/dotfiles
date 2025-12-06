#!/bin/bash

# https://github.com/devangshekhawat/Fedora-43-Post-Install-Guide
sudo dnf install @development-tools
sudo dnf install -y git curl wget p7zip p7zip-plugins fish ninja-build cmake ripgrep nodejs wl-clipboard ghostty neovim gh difftastic
curl -fsS https://dl.brave.com/install.sh | sh
sudo flatpak install flathub com.spotify.Client
flatpak install flathub md.obsidian.Obsidian

sudo dnf remove akregator elisa-player firefox   kleopatra   kmail   kontact   konsole   korganizer   kolourpaint   kcharselect   kmahjongg   kmines   kmouth   kpat   ktnef   kaddressbook   kamoso   skanpage   qrca   pim-data-exporter   neochat   "libreoffice*"   plasma-welcome   plasma-discover dragon

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
