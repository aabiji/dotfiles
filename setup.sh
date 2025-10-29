#!/bin/bash
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:agornostal/ulauncher -y

# Update and install base tools
sudo apt update && sudo apt install -y \
    git build-essential curl unzip p7zip-full fish gdb ninja-build \
    cmake alsa-utils printer-driver-all cloc gh gocryptfs acpi \
    wget gpg apt-transport-https snapd npm \
    ulauncher brightnessctl pamixer blueman hyprland wl-clipboard \
    ripgrep swaybg gammastep network-manager-gnome yaru-theme-gtk yaru-theme-icon libglib2.0-bin

sudo snap install obsidian --classic
sudo snap install nvim --classic
sudo snap install ghostty --classic
sudo snap install go --classic
sudo snap install spotify

curl -fsS https://dl.brave.com/install.sh | sh
curl -fsSL https://bun.sh/install | bash
curl -f https://zed.dev/install.sh | sh

# Install inter nerd font
wget "https://github.com/ayusshrathore/inter-nerd-font/raw/main/Inter%20Regular%20Nerd%20Font%20Complete.otf" -O /tmp/inter-nerd.otf
mkdir -p ~/.local/share/fonts
mv /tmp/inter-nerd.otf ~/.local/share/fonts/
fc-cache -fv

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
