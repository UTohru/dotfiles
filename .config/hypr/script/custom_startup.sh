#!/usr/bin/env bash

# ===
# check and startup
# ===

batch_cmd=""

# Notification
if builtin command -V dunst > /dev/null 2>&1; then
	bacth_cmd="$batch_cmd dispatch exec dunst ;"
fi

# im
if builtin command -V fcitx5 >/dev/null 2>&1; then
	batch_cmd="${batch_cmd} dispatch exec fcitx5 -rd ;"
elif builtin command -V fcitx >/dev/null 2>&1; then
	batch_cmd="${batch_cmd} dispatch exec fcitx -rd ;"
fi

# launcher
if [ -x "$(command -v ulauncher)" ]; then
	batch_cmd="${batch_cmd} dispatch exec systemctl --user start ulauncher ;"
	batch_cmd="${batch_cmd} keyword bind ALT,D,ulauncher-toggle ;"
elif [ -x "$(command -v dmenu)" ]; then
	batch_cmd="${batch_cmd} keyword bind ALT,D,dmenu_run ;"
fi


# pulseaudio  systemtray
if builtin command -V pasystray > /dev/null 2>&1; then
	batch_cmd="${batch_cmd} dispatch exec pasystray ;"
fi

# bluetooth
if builtin command -V blueman-applet > /dev/null 2>&1; then
	batch_cmd="${batch_cmd} dispatch exec blueman-applet ;"
fi

# NetworkManager
if builtin command -V nm-applet > /dev/null 2>&1; then
	batch_cmd="${batch_cmd} dispatch exec nm-applet --indicator ;"
fi

if [ -n "${batch_cmd}" ]; then
	hyprctl --batch "${batch_cmd}"
fi
