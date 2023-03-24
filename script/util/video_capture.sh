#!/usr/bin/env bash

filename=$(date +%F_%H%M%S)

if [ ! -d ~/Screenshots ]; then
	mkdir ~/Screenshots
fi

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
	wf-recorder -g "$(slurp)" -f $HOME/Screenshots/$filename.mp4
else
	slop=$(slop -f "%x %y %w %h %g %i") || exit 1
	read -r X Y W H G ID < <(echo $slop)
	#ffmpeg -f x11grab -s "$W"x"$H" -i $DISPLAY.0+$X,$Y -crf 19 $HOME/Pictures/$filename.webm
	ffmpeg -f x11grab -s "$W"x"$H" -i $DISPLAY.0+$X,$Y -crf 19 -vcodec libx264 -pix_fmt yuv420p $HOME/Screenshots/$filename.mp4
fi

notify-send 'Record saved under ~/Screenshots'
