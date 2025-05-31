set fish_greeting

set -gx EDITOR nvim
set -gx ANDROID_HOME ~/Android/Sdk
set -gx PATH $PATH $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools

alias vim="nvim"
alias gdb="gdb -q"
alias rm "rm -rf"
alias cp "cp -r"
alias ls "ls -a --color"

alias setup "~/journal/open.sh && yay -Syu"
alias journal "~/journal/journal.sh"
