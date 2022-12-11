# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH="$HOME/.local/bin:/usr/bin"
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
