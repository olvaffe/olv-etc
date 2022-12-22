# aliases.sh

# utils
alias ls='ls --color=auto'
alias less='less --use-color -R'
alias grep='grep --color=auto'
alias g='grep'
alias l='less'

alias vi=vim
alias sh=bash

# source control
alias gg='git grep --color'
alias sg='grep --exclude-dir=.svn --exclude-dir=.git -R'

alias fixssh='eval $(tmux showenv -s SSH_AUTH_SOCK)'

# debian
if command -v apt > /dev/null; then
	alias aS='apt search'
	alias aP='apt purge'
	alias dG='dpkg -l | grep'
	alias dL='dpkg -L'
	alias dS='dpkg -S'
fi
