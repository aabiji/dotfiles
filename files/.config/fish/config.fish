set fish_greeting

set -gx ANDROID_HOME ~/Android/Sdk
set -gx PATH $PATH $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools

alias gdb="gdb -q"
alias rm "rm -rf"
alias cp "cp -r"
alias ls "ls -a --color"

alias setup "~/journal/open.sh && sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo snap update && sudo snap clean"
alias journal "~/journal/journal.sh"
