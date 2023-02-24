#!/usr/bin/env bash
set -eo pipefail

# === create symlink for windows in wsl ===
#  ! Currently, it works only on Windows administrator's distribution
# 
# Arg1 : source_path
# Arg2(Optional) : destination_path (if omitted, current dir)

if [ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	echo WSL not found.
	exit 1
fi
if [ $# -eq 0 ] || [ $# -ge 3 ]; then
	echo ArgError: $*
	exit 1
fi

target_path=$(echo $1 | xargs wslpath -w)

if [ $# -eq 1 ]; then
	create_path=$(echo `pwd` | xargs wslpath -w)
	create_name=$(basename $1)
else
	if [ -f $1 ] && [ -d $2 ]; then
		# create filename ommit
		create_path=$(echo $2 | xargs wslpath -w)
		create_name=$(basename $1)
	else
		create_path=$(dirname $2 | xargs wslpath -w)
		create_name=$(basename $2)
	fi
fi

ps_arg="\"-command \`\"New-Item -ItemType SymbolicLink -Path $create_path -Name $create_name -Value $target_path\`\"\",\"-Debug\""

if command -V powershell.exe > /dev/null 2>&1; then
	powershell.exe -command start-process powershell -verb runas -ArgumentList $ps_arg
else
	echo "[powershell.exe] is not found."
fi

