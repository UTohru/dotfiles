#!/usr/bin/env bash

# if [ $# != 1 ]; then
# 	echo Error: $*
# 	exit 1
# fi

img=~/.config/i3/lock.png
maim $img
i3lock -i $img
