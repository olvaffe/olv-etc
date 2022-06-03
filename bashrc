# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH="$HOME/.local/bin"
PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PATH="$PATH:/usr/local/games:/usr/games"
export PATH

shopt -s checkwinsize

HISTSIZE=64000
HISTFILESIZE=64000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

PS1='\u@\h:\w\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|alacritty*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "$(TERM=xterm dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Alias definitions.
if [ -f $HOME/.bash_aliases ]; then
    . $HOME/.bash_aliases
fi
