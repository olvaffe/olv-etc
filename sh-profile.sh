# sh-profile.sh

# kill pre-existing ssh-agent
if [ -n "$SSH_AGENT_PID" ]; then
	eval $(ssh-agent -k) > /dev/null
fi

# Set SSH_AUTH_SOCK and let systemd socket activation start the
# respective service. Prefer gpg-agent unless ssh-agent is customized.
if [ -z "$SSH_AUTH_SOCK" ]; then
	if [ -e "/usr/bin/ssh-agent.openssh" ]; then
		SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/openssh_agent"
	else
		SSH_AUTH_SOCK="$(gpgconf -L agent-ssh-socket)"
	fi
	export SSH_AUTH_SOCK
fi

dbus-update-activation-environment --systemd SSH_AUTH_SOCK

[ -z "$WAYLAND_DISPLAY" -a $(tty) = "/dev/tty1" ] && \
	command -v sway > /dev/null && \
	exec systemctl --user --wait start sway-session.target

if [ "$SSH_AUTH_SOCK" = "$(gpgconf -L agent-ssh-socket)" ]; then
	gpg-connect-agent UPDATESTARTUPTTY /bye > /dev/null
fi

[ -f "$HOME/.config/sh/rc.sh" ] && . "$HOME/.config/sh/rc.sh"
