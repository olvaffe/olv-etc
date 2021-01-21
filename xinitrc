#!/bin/sh

setup_session() {
	if [ `basename "$0"` != ".xinitrc" ]; then
		return
	fi

	exec > $HOME/.xsession-errors 2>&1

	if [ -d /etc/X11/xinit/xinitrc.d ] ; then
		for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
			[ -x "$f" ] && . "$f"
		done
		unset f
	fi

	# see /etc/X11/Xsession.d

	eval $(gnome-keyring-daemon --start)
	export SSH_AUTH_SOCK

	export GTK_IM_MODULE=ibus
	export XMODIFIERS=@im=ibus
	export QT_IM_MODULE=ibus
	ibus-daemon -d -x
}

setup_inputs() {
	input_device=""

	dmi_id="/sys/devices/virtual/dmi/id"
	if grep -q Carbon "$dmi_id/product_version"; then
		input_device="SynPS/2 Synaptics TouchPad"
	elif grep -q IdeaPad "$dmi_id/product_version"; then
		input_device="MSFT0001:00 06CB:CE2D Touchpad"
	elif grep -q "XPS 13" "$dmi_id/product_name"; then
		input_device="DLL0665:01 06CB:76AD Touchpad"
	elif grep -q "Precision 5520" "$dmi_id/product_name"; then
		input_device="DLL07BF:01 06CB:7A13 Touchpad"
	fi

	if [ -n "$input_device" ]; then
		xinput set-prop "$input_device" "libinput Tapping Enabled" 1
		xinput set-prop "$input_device" "libinput Tapping Button Mapping Enabled" 0 1
		xinput set-prop "$input_device" "libinput Horizontal Scroll Enabled" 0
	fi
}

setup_outputs() {
	dpi=72
	xres=`xrandr | grep Screen | cut -d' ' -f 8`
	if [ $xres -ge 3840 ]; then
		dpi=288
	elif [ $xres -ge 1920 ]; then
		dpi=144
	fi
	echo "Xft.dpi: $dpi" | xrdb -merge
}

setup_xresources() {
	xrdb -merge $HOME/.Xresources
}

setup_gtk() {
	export NO_AT_BRIDGE=1
}

setup_autostart() {
	# see /etc/xdg/autostart

	nm-applet &
	xautolock -time 3 -locker "i3lock -c 000000" &
}

setup_session
setup_inputs
setup_outputs
setup_xresources
setup_gtk
setup_autostart

exec i3
