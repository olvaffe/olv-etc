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

dmi_id="/sys/devices/virtual/dmi/id"
if grep -q Carbon "$dmi_id/product_version"; then
	xrandr --dpi 144
	gnome-screensaver &
else
	xinput set-prop "DLL0665:01 06CB:76AD UNKNOWN" "libinput Tapping Enabled" 1
fi

exec i3
