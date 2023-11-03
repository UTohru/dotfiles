#!/usr/bin/env bash

# echo で改行が消える

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	if builtin command -V wl-copy > /dev/null 2>&1; then
		text="$(echo $(wl-paste -p))"
		echo "${text//- /}" | wl-copy -p
	fi
else
	if builtin command -V xclip > /dev/null 2>&1; then
		text="$(echo $(xclip -o))"
		echo "${text//- /}" | xclip -i
	fi
fi
