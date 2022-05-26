#!/usr/bin/env bash

# ===
# check and startup
# ===

# composite manager
comp=""
which compton > /dev/null 2>&1
if [ $? -eq 0 ]; then
	comp="compton"
fi

which picom > /dev/null 2>&1
if [ $? -eq 0 ]; then
	comp="picom"
fi

if [ -n $comp ]; then
	i3-msg "exec --no-startup-id $comp -b --config $HOME/.config/compton.conf"
fi


# NetworkManager
which nm-applet > /dev/null 2>&1
if [ $? -eq 0 ]; then
	i3-msg "exec --no-startup-id nm-applet"
fi

# pulseaudio  systemtray
which pasystray > /dev/null 2>&1
if [ $? -eq 0 ]; then
	i3-msg "exec --no-startup-id pasystray"
fi


# bluetooth
which blueman-applet > /dev/null 2>&1
if [ $? -eq 0 ]; then
	i3-msg "exec --no-startup-id blueman-applet"
fi
