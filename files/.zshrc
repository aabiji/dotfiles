# Aliases and exports
alias vim="nvim"
alias rm="rm -rf"
alias cp="cp -r"
alias ls="ls -a --color"
update="sudo pacman -Syu"
alias setup="~/journal/open.sh && $update"
alias journal="~/journal/journal.sh"
export EDITOR="nvim"

# Prompt with git support
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats '%F{blue}%s:(%f%F{red}%b%f%F{yellow}%u%f%F{blue})%f '

preexec() { unset vcs_info_msg_0_ }
precmd() { vcs_info }

setopt prompt_subst
PROMPT='%B%(?.%F{green}→%f.%F{red}→%f) %F{cyan}%~%f ${vcs_info_msg_0_}%b'

# Setup history
setopt histignorealldups
setopt sharehistory 
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
