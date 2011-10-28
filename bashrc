# If not running interactively, don't do anything
[ -z "$PS1" ] && return

PATH="~/.local/bin"
PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PATH="$PATH:/usr/local/games:/usr/games"
export PATH

# ignoredups and ignorespace
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

PS1='\u@\h:\w\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

if [ "$(uname -s)" == "Darwin" ]; then
	# MacPorts
	export PATH=/opt/local/sbin:/opt/local/bin:$PATH
	# do not copy dot underscore files
	export COPYFILE_DISABLE=true
fi

# Alias definitions.

# utils
alias g='grep'
alias l='less'

# source control
alias gg='git grep'
alias sg='grep --exclude-dir=.svn --exclude-dir=.git -R'

# dpkg
if which dpkg > /dev/null; then
	alias dl='dpkg -l'
	alias dL='dpkg -L'
	alias dg='dpkg -l | grep'
	alias dS='dpkg -S'
	alias di='sudo dpkg -i'
	alias dP='sudo dpkg -P'
fi

# apt-get/apt-cache
if which apt-get > /dev/null; then
	alias aU='sudo apt-get update'
	alias au='sudo apt-get upgrade'
	alias adu='sudo apt-get dist-upgrade'
	alias ai='sudo apt-get install'
	alias aP='sudo apt-get purge'

	alias aS='apt-cache search'
	alias as='apt-cache show'
	alias ap='apt-cache showpkg'
fi
