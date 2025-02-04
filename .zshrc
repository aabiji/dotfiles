# Aliases and exports
alias rm="rm -rf"
alias cp="cp -r"
alias ls="ls -a --color"
alias activate="source .venv/bin/activate" # activate python virtual environments
alias push="git add -p && git commit && git push"
update="sudo apt update && sudo apt upgrade -y && sudo snap refresh"
alias setup="~/journal/open.sh && $update"
alias journal="~/journal/journal.sh"
alias connect="bt-device -c 09:A6:90:34:CC:B2" # connect to bluetooth headphones

export EDITOR="vim"
export PATH=$PATH:/home/aabiji/.local/bin
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
. "$HOME/.cargo/env" # Rust cargo

# Android Studio
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Zig
export PATH=$PATH:/home/aabiji/zig-linux-x86_64-0.13.0

# Init git support
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats '%F{blue}%s:(%f%F{red}%b%f%F{yellow}%u%f%F{blue})%f '
precmd() { vcs_info }

# Setup prompt
setopt prompt_subst
PROMPT='%B%(?.%F{green}→%f.%F{red}→%f) %F{cyan}%1~%f ${vcs_info_msg_0_}%b'

bindkey -e # Use emacs keybindings even if our EDITOR is set to vi

# Setup history
setopt histignorealldups
setopt sharehistory 
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# bun completions
[ -s "/home/aabiji/.bun/_bun" ] && source "/home/aabiji/.bun/_bun"
