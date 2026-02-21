set fish_greeting

function fish_prompt
    # Git branch (keeping your current logic)
    set_color normal
    set branch (git symbolic-ref --short HEAD 2> /dev/null)
    if test "$branch" != ""
        echo -n "($branch) "
    end

    # User @ Hostname in Bash-style colors
    set_color green
    echo -n (whoami)
    echo -n "@"
    echo -n (prompt_hostname)

    # The colon and directory
    set_color normal
    echo -n ":"

    set_color green
    echo -n (prompt_pwd)

    # The prompt symbol ($ for user, # for root)
    set_color white
    echo -n "\$ "
    set_color normal
end

# Backup my journal to github
function journal
    pushd ~/journal > /dev/null
    git add . && git commit -m "update" && git push
    popd > /dev/null
end

# android studio
set -gx ANDROID_SDK_ROOT ~/Android/Sdk
set -gx PATH $PATH ~/Android/Sdk/cmdline-tools/latest/bin

set -gx ANDROID_HOME ~/Android/Sdk
set -gx PATH $PATH $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools

# flutter
set -gx PATH $PATH ~/flutter/flutter/bin
set --export PATH "$HOME/android-studio/flutter/bin" $PATH

set -gx EDITOR "nvim"

alias vim="nvim"
alias gdb="gdb -q"
alias rm "rm -rf"
alias cp "cp -r"
alias ls "ls -a --color"
