# paths.sh

PATH="/usr/bin"
[ -f "/etc/arch-release" ] || PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:$PATH:/sbin:/bin"

prepend_path() {
	[ -d "$1" ] && PATH="$1:$PATH"
}

if [ -n "$CROS_WORKON_SRCROOT" ]; then
	prepend_path "/opt/bin"
	prepend_path "$CROS_WORKON_SRCROOT/chromite/bin"
	prepend_path "$CROS_WORKON_SRCROOT/src/chromium/depot_tools"
fi

prepend_path "$HOME/.local/bin"
prepend_path "$HOME/projects/depot_tools"
prepend_path "$HOME/android/sdk/build-tools/30.0.3"
prepend_path "$HOME/android/sdk/platform-tools"

unset -f prepend_path
export PATH

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
