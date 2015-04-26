#!/bin/sh

exec > $HOME/.xsession-errors 2>&1

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

export NO_AT_BRIDGE=1

eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
ibus-daemon -d -x

nm-applet &

xrdb -merge ~/.Xresources
synclient TouchpadOff=0 ClickPad=1

exec i3
