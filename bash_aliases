# utils
alias g='grep'
alias l='less'

# source control
alias gg='git grep --color'
alias sg='grep --exclude-dir=.svn --exclude-dir=.git -R'

# PTT
alias ptt='ssh bbsu@ptt.cc'
alias ptt2='ssh bbsu@ptt2.cc'

# dpkg
if which dpkg > /dev/null 2>&1; then
	alias dl='dpkg -l'
	alias dL='dpkg -L'
	alias dg='dpkg -l | grep'
	alias dS='dpkg -S'
	alias di='sudo dpkg -i'
	alias dP='sudo dpkg -P'
fi

# apt-get/apt-cache
if which apt-get > /dev/null 2>&1; then
	alias aU='sudo apt-get update'
	alias au='sudo apt-get upgrade'
	alias adu='sudo apt-get dist-upgrade'
	alias ai='sudo apt-get install'
	alias aP='sudo apt-get purge'

	alias aS='apt-cache search'
	alias as='apt-cache show'
	alias ap='apt-cache showpkg'
fi

alias y=ydict.js

alias vi=vim
export EDITOR=vim
