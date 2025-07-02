set fish_greeting

set -gx ANDROID_HOME ~/Android/Sdk
set -gx PATH $PATH $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools
set -gx PATH $PATH ~/zig/
set -gx EDITOR "nvim"

alias setup_emsdk ". /home/aabiji/emsdk/emsdk_env.fish"

alias vim="nvim"
alias gdb="gdb -q"
alias rm "rm -rf"
alias cp "cp -r"
alias ls "ls -a --color"

alias setup "~/journal/open.sh && sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo snap refresh"
alias journal "~/journal/journal.sh"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
