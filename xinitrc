#!/bin/sh

export NO_AT_BRIDGE=1

if [ `basename "$0"` = ".xinitrc" ]; then
	exec > $HOME/.xsession-errors 2>&1

	if [ -d /etc/X11/xinit/xinitrc.d ] ; then
		for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
			[ -x "$f" ] && . "$f"
		done
		unset f
	fi

	eval $(gnome-keyring-daemon --start)
	export SSH_AUTH_SOCK

	export GTK_IM_MODULE=ibus
	export XMODIFIERS=@im=ibus
	export QT_IM_MODULE=ibus
	ibus-daemon -d -x
fi

nm-applet &
xautolock -time 5 -locker "i3lock -c 000000" &

xrdb -merge ~/.Xresources

dmi_id="/sys/devices/virtual/dmi/id"
if grep -q Carbon "$dmi_id/product_version"; then
	xrandr --dpi 144
	echo "Xft.dpi: 144" | xrdb -merge

	xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1
	xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Horizontal Scroll Enabled" 0
elif grep -q "XPS 13" "$dmi_id/product_name"; then
	xinput set-prop "DLL0665:01 06CB:76AD UNKNOWN" "libinput Tapping Enabled" 1
fi

exec i3
