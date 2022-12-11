# ~/.bash_aliases

# enable color support of ls and also add handy aliases
if command -v dircolors > /dev/null; then
    eval "$(TERM=xterm dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# utils
alias g='grep'
alias l='less'

alias vi=vim
alias sh=bash

# source control
alias gg='git grep --color'
alias sg='grep --exclude-dir=.svn --exclude-dir=.git -R'

alias fixssh='eval $(tmux showenv -s SSH_AUTH_SOCK)'
