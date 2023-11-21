# sh-paths.sh

append_path() {
	[ -d "$1" ] && PATH="$PATH:$1"
}

prepend_path() {
	[ -d "$1" ] && PATH="$1:$PATH"
}

PATH="/usr/bin"
[ -f "/etc/arch-release" ] || PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:$PATH:/sbin:/bin"

if [ -n "$CROS_WORKON_SRCROOT" ]; then
	append_path "/opt/bin"
	append_path "$CROS_WORKON_SRCROOT/chromite/sdk/bin"
	append_path "$CROS_WORKON_SRCROOT/chromite/bin"
else
	append_path "$HOME/chromiumos/depot_tools"
fi

prepend_path "$HOME/android/sdk/build-tools/34.0.0"
prepend_path "$HOME/android/sdk/platform-tools"
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/.local/bin"

unset -f append_path
unset -f prepend_path

export PATH
