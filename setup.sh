#!/bin/bash

# Install prerequisites
sudo apt install curl wget gpg

curl -fsSL https://bun.sh/install | bash # Install bun
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # Install rust

# Setup package manager for vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg 

# Install packages
sudo apt update
sudo apt install git kitty cloc python3-pip build-essential yt-dlp code p7zip-full gocryptfs zsh golang-go gnome-tweaks wl-clipboard ripgrep
sudo snap install nvim --classic

# Install obsidian
curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
| grep "browser_download_url.*deb" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
mv *.deb obsidian.deb
sudo apt install ./obsidian.deb

# Temporarily install gh
curl -s https://api.github.com/repos/cli/cli/releases/latest \
| jq -r '.assets[] | select(.name | test("linux_amd64")) | .browser_download_url' \
| xargs curl -L -o gh.tar.gz
7z x gh.tar.gz && 7z x data.tar
sudo mv usr/bin/gh /usr/bin

# Clone all repos to the dev/archive folder
cd ~ && mkdir -p dev/archive && cd dev/archive
ssh-keygen && gh auth login
gh repo list aabiji --limit 4000 | while read -r repo _; do
    gh repo clone "$repo" "$repo"
done
mv ~/dev/archive/aabiji/* ~/dev/archive
sudo rm /usr/bin/gh
rm -r ~/dev/archive/aabiji

# Setup journal and dotfiles
cd ~ && mv dev/archive/journal .
mv ~/dev/archive/dotfiles ~/dev/dotfiles

# Symlink my dotfiles
traverse() {
    local dir="$1"
    for entry in "$dir"/.* "$dir"/*; do
        filename=$(basename "$entry") # Get just the filename
        if [[
            "$filename" == "." ||
            "$filename" == ".." ||
            "$filename" == *.sh ||
            "$filename" == .\*  ||
            "$filename" == ".git" ]]; then
            continue # Skip unwanted entries
        fi

        if [[ -d "$entry" ]]; then
            traverse "$entry"  # Go into the directory 
        else
            ln -s "$entry" "/home/aabiji/$filename" # Create the symlink
        fi
    done
}
traverse ~/dev/dotfiles

# Switch to zsh
chsh -s /bin/zsh aabiji

# Update 
sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo snap refresh 

# Setup reminder cronjob
crontab -l > mycron
job="0 * * * * DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus notify-send 'Hourly reminder' 'Get up, look around and stretch' -u critical"
echo "$job" >> mycron
crontab mycron
rm mycron
