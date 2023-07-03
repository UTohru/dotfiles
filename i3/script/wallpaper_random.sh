#!/usr/bin/env bash

# if [ $# != 1 ]; then
# 	echo Error: $*
# 	exit 1
# fi

# exec_always --no-startup-id feh --randomize --bg-scale ~/.config/i3/wallpaper/*

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	wp=`find ~/.config/sway/wallpaper/ -type f | sort -R | tail -n 1`
	swaymsg "output '*' background $wp fill"
else
	i3-msg "exec --no-startup-id feh --randomize --bg-scale ~/.config/i3/wallpaper/"
fi
