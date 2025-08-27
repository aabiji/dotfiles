#!/bin/bash

sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg

# Update and install base tools
sudo apt update && sudo apt install -y \
    git build-essential curl unzip p7zip-full fish gdb ninja-build \
    cmake alsa-utils printer-driver-all cloc gh gocryptfs acpi wl-clipboard \
    wget gpg apt-transport-https ghostty code

sudo snap install --edge nvim --classic
sudo snap install obsidian --classic

curl -LsSf https://astral.sh/uv/install.sh | sh
curl -fsS https://dl.brave.com/install.sh | sh
curl -fsSL https://bun.sh/install | bash

# Setup GitHub auth and clone repos
cd ~ && mkdir -p ~/dev/archive && cd ~/dev/archive
gh auth login
gh repo list aabiji --limit 1000 | awk '{print $1; }' | xargs -L1 gh repo clone

mv ~/dev/archive/aabiji/* ~/dev/archive
rm -r ~/dev/archive/aabiji

# move journal and dotfiles
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
sudo apt purge gh
sudo apt update && sudo apt upgrade -y
