# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="\u@\h:\w\$ "
# set window title as well
PS1="\[\e]2;\u@\h:\w\a\]$PS1"

HISTSIZE=64000
HISTFILESIZE=64000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

if command -v infocmp > /dev/null; then
	if ! infocmp "$TERM" > /dev/null 2>&1; then
		TERM="xterm-256color"
	fi

	if [ -z "$COLORTERM" ]; then
		export COLORTERM="truecolor"
	fi
fi

if command -v dircolors > /dev/null; then
    eval "$(dircolors -b)"
fi

# for cros chroot
if [ -n "$CROS_WORKON_SRCROOT" ]; then
	PS1="\u@cros-sdk:\w\$ "
	unset LESS
fi

[ -f "$HOME/.bash_paths" ] && . "$HOME/.bash_paths"
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
