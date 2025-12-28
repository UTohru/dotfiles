#!/usr/bin/env bash

# ===
# check and startup
# ===


if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	cmd=swaymsg
else
	cmd=i3-msg
fi

if builtin command -V dunst > /dev/null 2>&1; then
	$cmd "exec --no-startup-id dunst"
fi

if [ -x "$(command -v ulauncher)" ]; then
	$cmd "exec --no-startup-id systemctl --user start ulauncher"
fi

if builtin command -V fcitx5 >/dev/null 2>&1; then
	$cmd "exec --no-startup-id fcitx5 -rd"
elif builtin command -V fcitx >/dev/null 2>&1; then
	$cmd "exec --no-startup-id fcitx -rd"
fi


if [ "$XDG_SESSION_TYPE" = "x11" ]; then
	# compositor
	if builtin command -V compton > /dev/null 2>&1; then
		comp="compton"
	elif builtin command -V picom > /dev/null 2>&1; then
		comp="picom"
	fi

	if [ -n $comp ]; then
		$cmd "exec --no-startup-id $comp -b --config $HOME/.config/compton.conf"
	fi

	chassis_type=`cat /sys/class/dmi/id/chassis_type`
	if [ "$chassis_type" -ne 10 ] && [ "$chassis_type" -ne 9 ]; then
		$cmd "exec --no-startup-id xset s off"
		$cmd "exec --no-startup-id xset -dpms"
	fi
fi

if builtin command -V conky > /dev/null 2>&1; then
	$cmd "exec --no-startup-id conky"
fi

# NetworkManager
if builtin command -V nm-applet > /dev/null 2>&1; then
	$cmd "exec --no-startup-id nm-applet --indicator"
fi

# bluetooth
if builtin command -V blueman-applet > /dev/null 2>&1; then
	$cmd "exec --no-startup-id blueman-applet"
fi

if builtin command -V google-drive-ocamlfuse > /dev/null 2>&1; then
	${HOME}/.config/i3/script/mount_gdrive.sh
fi

