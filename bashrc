# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH="/usr/bin"
[ -f "/etc/arch-release" ] || PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:$PATH:/sbin:/bin"

if [ -n "$CROS_WORKON_SRCROOT" ]; then
	PATH="/opt/bin:$CROS_WORKON_SRCROOT/chromite/bin:$CROS_WORKON_SRCROOT/src/chromium/depot_tools:$PATH"
fi

[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/projects/depot_tools" ] && PATH="$HOME/projects/depot_tools:$PATH"
[ -d "$HOME/android/sdk/build-tools/30.0.3" ] && PATH="$HOME/android/sdk/build-tools/30.0.3:$PATH"
[ -d "$HOME/android/sdk/platform-tools" ] && PATH="$HOME/android/sdk/platform-tools:$PATH"

export PATH

shopt -s checkwinsize

HISTSIZE=64000
HISTFILESIZE=64000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

PS1="\u@\h:\w\$ "
# set window title as well
PS1="\[\e]2;\u@\h:\w\a\]$PS1"

[ -f "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
