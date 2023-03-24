#!/usr/bin/env bash


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
		if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
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

case "$1" in
	lock | suspend | hibernate)
		if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
			img=~/.config/sway/lock.png
			locker=swaylock
		else
			img=~/.config/i3/lock.png
			locker=i3lock
		fi

		if builtin command -V maim > /dev/null 2>&1; then
			maim $img
		elif builtin command -V grim > /dev/null 2>&1; then
			grim $img
		fi
		$locker -i $img
		;;
	*)
		;;
esac

exit 0
