#!/bin/bash
set -e

# Update system
sudo pacman -Syu --noconfirm

# Install base development tools
sudo pacman -S --noconfirm --needed gnome gdm gdm-settings \
    base-devel git curl wget unzip p7zip fish gdb ninja cmake \
    alsa-utils cups cloc acpi ripgrep nodejs wl-clipboard ghostty neovim \
    qt5-wayland qt6-wayland gvfs gvfs-mtp gvfs-gphoto2 \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber github-cli gnome-tweaks \
    pavucontrol sof-firmware alsa-ucm-conf wayland xorg-xwayland \
    noto-fonts yaru-gtk-theme yaru-icon-theme ttf-ubuntu-font-family

yay -R gnome-boxes gnome-builder \
    gnome-calendar gnome-contacts gnome-maps gnome-music \
    gnome-chess gnome-weather gnome-logs gnome-clocks gnome-software \
    gnome-calculator gnome-calls gnome-characters \
    gnome-connections gnome-console gnome-disk-utility gnome-font-viewer \
    gnome-mahjongg gnome-mines gnome-nibbles gnome-remote-desktop gnome-robots \
    gnome-sound-recorder gnome-sudoku gnome-system-monitor gnome-text-editor \
    gnome-themes-extra gnome-tour d-spy lightsoff quadrapassel swell-foop ghex \
    thunar flameshot file-roller epiphany malcontent ulauncher kvantum \
    simple-scan dconf-editor decibels showtime

wget "https://github.com/ayusshrathore/inter-nerd-font/raw/main/Inter%20Regular%20Nerd%20Font%20Complete.otf" -O /tmp/inter-nerd.otf
mkdir -p ~/.local/share/fonts
mv /tmp/inter-nerd.otf ~/.local/share/fonts/
fc-cache -fv

# Install yay (AUR helper) if not already installed
if ! command -v yay &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

yay -S --noconfirm --needed brave-bin spotify obsidian docker docker-compose

# Install bun
curl -fsSL https://bun.sh/install | bash

# Setup directories
mkdir -p ~/dev/archive ~/Pictures

# Setup GitHub auth and clone repos
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

# Enable services
sudo systemctl enable bluetooth.service
sudo systemctl enable cups.service
sudo systemctl enable docker.service
sudo systemctl enable gdm.service

# Set up GTK3 theme
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Yaru-dark
gtk-icon-theme-name=Yaru
gtk-font-name=Sans 10
gtk-cursor-theme-name=Yaru
EOF

# Set up GTK2 theme
cat > ~/.gtkrc-2.0 << 'EOF'
gtk-theme-name="Yaru-dark"
gtk-icon-theme-name="Yaru"
EOF
