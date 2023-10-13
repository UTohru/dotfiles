#!/usr/bin/env bash
set -e

# exec_always --no-startup-id feh --randomize --bg-scale ~/.config/i3/wallpaper/*

if [ ! -d ~/Screenshots ]; then
	mkdir ~/Screenshots
fi

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	grim -g "$(slurp)" ~/Screenshots/$(date '+%F_%H%M').png
else
	maim -s ~/Screenshots/$(date '+%F_%H%M').png
fi

notify-send 'Record saved under ~/Screenshots'
