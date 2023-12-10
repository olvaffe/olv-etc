# sh-rc.sh

# If not running interactively, don't do anything
case "$-" in
	*i*) ;;
	*) return;;
esac

[ -f "$HOME/.config/sh/paths.sh" ] && . "$HOME/.config/sh/paths.sh"
[ -f "$HOME/.config/sh/aliases.sh" ] && . "$HOME/.config/sh/aliases.sh"

[ -z "$WAYLAND_DISPLAY$DISPLAY" -a $(tty) = "/dev/tty1" ] && exec sway-session

HISTFILE="$HOME/.local/state/sh.history"
HISTSIZE=64000
HISTFILESIZE=64000
HISTCONTROL=ignoredups:erasedups

if [ -n "$BASH_VERSION" ]; then
	shopt -s histappend

	hn="$(uname -n)"
	case "$hn" in
		olv-glaptop4*)
			hn="x1"
			;;
		olv-ct-22*)
			hn="ct"
			;;
		*)
			hn="\h"
			;;
	esac

	# for cros chroot
	if [ -n "$CROS_WORKON_SRCROOT" ]; then
		hn="cros-sdk"

		unset LESS
		cd ~/chromiumos/src/scripts
	fi

	PS1="\u@$hn:\w\$ "
	# set window title as well
	PS1="\[\e]2;\u@$hn:\w\a\]$PS1"

	unset hn
else
	PS1='$USER:$PWD$ '
fi

if command -v infocmp > /dev/null; then
	if ! infocmp "$TERM" > /dev/null 2>&1; then
		TERM="xterm-256color"
	fi

	if [ -z "$COLORTERM" ]; then
		export COLORTERM="truecolor"
	fi
fi

if command -v dircolors > /dev/null; then
    eval $(dircolors -b)
fi
