#!/usr/bin/env bash

# if [ $# != 1 ]; then
# 	echo Error: $*
# 	exit 1
# fi

filename=$(date +%F_%H%M%S)
slop=$(slop -f "%x %y %w %h %g %i") || exit 1
read -r X Y W H G ID < <(echo $slop)
#ffmpeg -f x11grab -s "$W"x"$H" -i $DISPLAY.0+$X,$Y -crf 19 $HOME/Pictures/$filename.webm
ffmpeg -f x11grab -s "$W"x"$H" -i $DISPLAY.0+$X,$Y -crf 19 -vcodec libx264 -pix_fmt yuv420p $HOME/Pictures/$filename.mp4

#ffmpeg -i $HOME/Pictures/$filename.webm $HOME/Pictures/$filename.mp4
#ffmpeg -i $HOME/Pictures/$filename.webm -vcodec libx264 -pix_fmt yuv420p $HOME/Pictures/$filename.mp4
#rm $HOME/Pictures/$filename.webm

notify-send 'Record saved under ~/Pictures'
