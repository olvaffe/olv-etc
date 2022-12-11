# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f "$HOME/.bash_paths" ] && . "$HOME/.bash_paths"
[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"

PS1="\u@\h:\w\$ "
# set window title as well
PS1="\[\e]2;\u@\h:\w\a\]$PS1"

HISTSIZE=64000
HISTFILESIZE=64000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# for cros chroot
if [ -n "$CROS_WORKON_SRCROOT" ]; then
	PS1="\u@cros-sdk:\w\$ "
	unset LESS
fi
