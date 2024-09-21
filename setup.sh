#!/bin/sh

# Setup package manager for vscode
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg 

# Setup package manager for gh
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

curl -fsSL https://bun.sh/install | bash # Install bun
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # Install rust

sudo apt update
sudo apt install vim git cloc python3-pip build-essential curl yt-dlp ripgrep wezterm code p7zip-full gocryptfs
sudo snap install obsidian --classic # Install Obsidian

# Install google chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt -f install
sudo apt - fix-broken install

# Install the JetBrains Mono font
curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest \
	| grep ".*zip" \
	| cut -d : -f 2,3 \
	| tr -d \" \
	| wget -qi -
7z x *.zip
sudo mv fonts/ttf/JetBrainsMono-Regular.ttf /usr/share/fonts/truetype/
sudo fc-cache -f -v

# Clone all repos to the dev/archive folder
sudo apt install gh
cd ~ && mkdir -p dev/archive && cd dev/archive
ssh-keygen && gh auth login
gh repo list aabiji --limit 4000 | while read -r repo _; do
    gh repo clone "$repo" "$repo"
done
sudo apt purge gh # TODO: remove the repository too

# Setup journal
cd ~ && mv dev/archive/journal .

# Update 
sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo snap update

# Symlink my config files
cd ~/dev/archive/configs/dotfiles
for entry in ~/dev/archive/configs/dotfiles/.*; do
    filename=$(basename "$entry") # Get just the filename
    if [[ "$filename" == "." || "$filename" == ".." ]]; then
        continue # Skip . and .. entries
    fi
    ln -s "$entry" "/home/aabiji/$filename" # Create the symlink
done
