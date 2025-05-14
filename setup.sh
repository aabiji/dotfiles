#!/bin/bash

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

# Install stuff
yay -S brave-bin spotify ghostty obsidian github-cli unzip 7zip gocryptfs fish gdb tmux ninja openssh cmake alsa-utils plasma-pa system-config-printer print-manager samsung-unified-driver-printer wl-clipboard cloc mold spectacle plasma-systemmonitor neovim
yay -R yakuake okular kate elisa firefox konsole
curl -fsSL https://bun.sh/install | bash

# Clone all repos to the dev/archive folder
cd ~ && mkdir -p dev/archive && cd dev/archive
gh auth login
gh repo list aabiji --limit 4000 | while read -r repo _; do
    gh repo clone "$repo" "$repo"
done
mv ~/dev/archive/aabiji/* ~/dev/archive
rm -r ~/dev/archive/aabiji yay-bin

# Setup journal and dotfiles
cd ~ && mv dev/archive/journal .
mv ~/dev/archive/dotfiles ~/dev/dotfiles

# Symlink my dotfiles
traverse() {
    local dir="$1"
    local base="$2"

    shopt -s dotglob  # Ensure hidden files are expanded
    for entry in "$dir"/* "$dir"/.*; do
        filename=$(basename "$entry")

        # Skip unwanted files and ensure the entry exists
        if [[ ! -e "$entry" || "$filename" == "." || "$filename" == ".." || "$filename" == *.sh || "$filename" == ".git" ]]; then
            continue
        fi

        # Compute the relative path for symlink destination
        relative_path="${entry#$base/}"
        target="$HOME/$relative_path"

        if [[ -d "$entry" ]]; then
            mkdir -p "$target"
            traverse "$entry" "$base"
        else
            ln -sf "$entry" "$target"
        fi
    done
    shopt -u dotglob  # Reset to default behavior
}
traverse "$HOME/dev/dotfiles/files" "$HOME/dev/dotfiles/files"

# Switch to fish 
chsh -s /bin/fish aabiji

# Update
sudo pacman -Syu
