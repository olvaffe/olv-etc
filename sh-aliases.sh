# sh-aliases.sh

# utils
alias ls='ls --color=auto'
alias less='less --use-color -R'
alias grep='grep --color=auto'
alias g='grep'
alias l='less'

# source control
alias gg='git grep --color'
alias sg='grep --exclude-dir=.svn --exclude-dir=.git -R'

alias fixssh='eval $(tmux showenv -s SSH_AUTH_SOCK)'

if command -v vim > /dev/null; then
	alias vi='vim'
fi
if command -v bash > /dev/null; then
	alias sh='bash'
fi

# debian
if command -v apt > /dev/null; then
	alias aS='apt search'
	alias aI='sudo apt install'
	alias aP='sudo apt purge'
	alias dG='dpkg -l | grep'
	alias dL='dpkg -L'
	alias dS='dpkg -S'
fi
