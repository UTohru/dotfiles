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
		default_color=696969
		if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
			img=~/.config/sway/lock.png
			locker=swaylock
			ss=grim
		elif [ "$XDG_SESSION_TYPE" == "x11" ]; then
			img=~/.config/i3/lock.png
			locker=i3lock
			ss=maim
		fi

		if builtin command -V $ss > /dev/null 2>&1; then
			$ss $img
		fi

		if [ -f $img ]; then
			if [ "$locker" = "swaylock" ]; then
				$locker -e -i $img --effect-blur 7x5 --effect-vignette 0.5:0.5 --daemonize
			else
				$locker -e -i $img
			fi
		else
			$locker -e -c $default_color
		fi
		;;
	*)
		;;
esac

exit 0
