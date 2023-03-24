#!/usr/bin/env bash

# ===
# check and startup
# ===


if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
	cmd=swaymsg
else
	cmd=i3-msg
fi

if builtin command -V dunst > /dev/null 2>&1; then
	$cmd "exec --no-startup-id dunst"
fi

if builtin command -V fcitx5 >/dev/null 2>&1; then
	$cmd "exec --no-startup-id fcitx5 -rd"
elif builtin command -V fcitx >/dev/null 2>&1; then
	$cmd "exec --no-startup-id fcitx -rd"
fi


if [ "$XDG_SESSION_TYPE" == "x11" ]; then
	# compositor
	if builtin command -V compton > /dev/null 2>&1; then
		comp="compton"
	elif builtin command -V picom > /dev/null 2>&1; then
		comp="picom"
	fi

	if [ -n $comp ]; then
		$cmd "exec --no-startup-id $comp -b --config $HOME/.config/compton.conf"
	fi

	# which conky > /dev/null 2>&1
	# if [ $? -eq 0 ]; then
	# 	$cmd "exec --no-startup-id conky"
	# fi
fi

# NetworkManager
if builtin command -V nm-applet > /dev/null 2>&1; then
	$cmd "exec --no-startup-id nm-applet --indicator"
fi

# pulseaudio  systemtray
if builtin command -V pasystray > /dev/null 2>&1; then
	$cmd "exec --no-startup-id pasystray"
fi

# bluetooth
if builtin command -V blueman-applet > /dev/null 2>&1; then
	$cmd "exec --no-startup-id blueman-applet"
fi

