#!/usr/bin/env bash
set -e

if [ ! -d ~/Screenshots ]; then
	mkdir ~/Screenshots
fi

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	grim -g "$(slurp)" ~/Screenshots/$(date '+%F_%H%M%S').png
else
	maim -s ~/Screenshots/$(date '+%F_%H%M%S').png
fi

notify-send 'Record saved under ~/Screenshots'
