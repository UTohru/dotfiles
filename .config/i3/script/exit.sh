#!/usr/bin/env bash

# lockscreen
case "$1" in
	lock | suspend | hibernate)
		default_color=696969
		lock_args="-e"

		# screen shot
		if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
			imgdir=~/.config/sway
			locker=swaylock
			$lock_args="$lock_args -f"
			if [ -x "$(command -v mogrify)" -a -x "$(command -v grim)" ]; then
				for MONITOR in `swaymsg -t get_outputs | jq -r '.[] | select(.active == true) | .name'`
				do
					img="$imgdir/${MONITOR}-lock.png"
					grim -o "${MONITOR}" "${img}"
					mogrify $img -blur 7x5 -background black -vignette 0x80-20%-2% $img
					lock_args="${lock_args} --image ${MONITOR}:${img}"
				done
			fi
		elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
			img=~/.config/i3/lock.png
			locker=i3lock
			if [ -x "$(command -v mogrify)" -a -x "$(command -v maim)" ]; then
				maim $img
				mogrify $img -blur 7x5 -background black -vignette 0x80-20%-2% $img
				lock_args="${lock_args} -i $img"
			fi
		fi

		$locker $lock_args
		;;
	*)
		;;
esac

case "$1" in
	lock)
		;;
	suspend)
		systemctl suspend
		;;
	hibernate)
		systemctl hibernate
		;;
	logout)
		if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
			cmd=swaymsg
		else
			cmd=i3-msg
		fi
		$cmd exit
		;;
	shutdown)
		systemctl poweroff
		;;
	reboot)
		systemctl reboot
		;;
	*)
		notify-send '$0 : invalid arguments'
		exit 2
		;;
esac


exit 0
