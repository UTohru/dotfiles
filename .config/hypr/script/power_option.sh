#!/usr/bin/env bash

batch_cmd=""

chassis_type=`cat /sys/class/dmi/id/chassis_type`

# laptop
if [ $chassis_type -eq 10 ] || [ $chassis_type -eq 9 ]; then
	batch_cmd="$batch_cmd keyword decoration:blur:enabled false ;"
	batch_cmd="$batch_cmd keyword decoration:drop_shadow no ;"
	# batch_cmd="$batch_cmd keyword misc:vfr true ;" # defualt
fi

if [ -n "${batch_cmd}" ]; then
	hyprctl --batch "${batch_cmd}"
fi

