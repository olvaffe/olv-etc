# sh-paths.sh

PATH="/usr/bin"
[ -f "/etc/arch-release" ] || PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:$PATH:/sbin:/bin"

prepend_path() {
	[ -d "$1" ] && PATH="$1:$PATH"
}

append_path() {
	[ -d "$1" ] && PATH="$PATH:$1"
}

prepend_path "$HOME/android/sdk/build-tools/36.0.0"
prepend_path "$HOME/android/sdk/platform-tools"
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/.pip/bin"
prepend_path "$HOME/.local/bin"

append_path "$HOME/chromiumos/depot_tools"

unset -f append_path
unset -f prepend_path

export PATH
