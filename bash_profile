# ~/.bash_profile, used by login shells

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -z "$DISPLAY$WAYLAND_DISPLAY" && -n $XDG_VTNR && $XDG_VTNR -le 1 ]] && exec sway-session
