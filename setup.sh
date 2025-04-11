#!/bin/bash

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

# Install packages
yay -Sy brave-bin spotify ghostty obsidian github-cli 7zip gocryptfs fish ttf-jetbrains-mono ttf-ubuntu-font-family gdb man vim visual-studio-code-bin

# Install hyprland and friends
# yay -S hyprland swaybg waybar blueman brightnessctl nautilus

# Or install gnome and remove bloat
sudo pacman -R gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-connections gnome-console gnome-contacts gnome-logs gnome-maps gnome-tour gnome-usage gnome-user-docs gnome-user-share gnome-weather gnome-music epiphany totem malcontent sushi evince decibels

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
