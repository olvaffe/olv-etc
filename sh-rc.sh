# sh-rc.sh

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

[ -f "$HOME/olv-etc/sh-paths.sh" ] && . "$HOME/olv-etc/sh-paths.sh"
[ -f "$HOME/olv-etc/sh-aliases.sh" ] && . "$HOME/olv-etc/sh-aliases.sh"

HISTFILE="$HOME/.local/state/sh.history"
HISTSIZE=64000
HISTFILESIZE=64000
HISTCONTROL=ignoredups:erasedups

if [ -n "$BASH_VERSION" ]; then
	shopt -s histappend

	hn="$(uname -n)"
	case "$hn" in
		olv-glaptop*)
			hn="x1"
			;;
		olv-ct*)
			hn="ct"
			;;
		*)
			hn="\h"
			;;
	esac

	PS1="\u@$hn:\w\$ "
	# set window title as well
	PS1="\[\e]2;\u@$hn:\w\a\]$PS1"

	unset hn
else
	PS1='$USER:$PWD$ '
fi

if command -v tput > /dev/null; then
	tput longname > /dev/null 2>&1 || TERM="xterm-256color"
	export COLORTERM="truecolor"
fi

if command -v dircolors > /dev/null; then
    eval $(dircolors -b)
fi
