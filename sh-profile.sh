# sh-profile.sh

[ -f "$HOME/.config/sh/paths.sh" ] && . "$HOME/.config/sh/paths.sh"

dbus-update-activation-environment --systemd PATH

[ -z "$WAYLAND_DISPLAY" -a $(tty) = "/dev/tty1" ] && \
	command -v sway > /dev/null && \
	exec sway-session

if [ -z "$SSH_AUTH_SOCK" -a -z "$SSH_CONNECTION" ]; then
	export SSH_AUTH_SOCK="$(gpgconf -L agent-ssh-socket)"
	gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
fi

[ -f "$HOME/.config/sh/rc.sh" ] && . "$HOME/.config/sh/rc.sh"
