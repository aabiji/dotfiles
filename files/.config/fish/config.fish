set fish_greeting

function fish_prompt
    # Current working directory
    set_color --bold green
    set -g fish_prompt_pwd_dir_length 0
    echo -n " "
    echo -n (prompt_pwd)

    # Git branch, if any
    set_color normal
    set branch (git symbolic-ref --short HEAD 2> /dev/null)   
    if test "$branch" != "" -a "$branch" != "HEAD"
        echo -n " ($branch)"
    end
    echo -n " % "
end

# Update packages and snaps
function update
  sudo apt update -y
  sudo apt upgrade -y
  sudo snap refresh
  sudo apt autoremove -y
  LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read -l snapname revision
      sudo snap remove "$snapname" --revision="$revision"
  end
end

# Mkdir and cd in one command
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

set -gx ANDROID_SDK_ROOT ~/Android/Sdk
set -gx PATH $PATH ~/Android/Sdk/cmdline-tools/latest/bin

set -gx ANDROID_HOME ~/Android/Sdk
set -gx PATH $PATH $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools
set -gx EDITOR "nvim"

alias vim="nvim"
alias gdb="gdb -q"
alias rm "rm -rf"
alias cp "cp -r"
alias ls "ls -a --color"
alias journal "~/journal/journal.sh"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# zed cli
set --export PATH ~/.local/bin $PATH

# rust
export RUSTUP_HOME=/home/aabiji/.rustup
