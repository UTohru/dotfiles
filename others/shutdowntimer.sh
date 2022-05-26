#!/usr/bin/env bash

# 切り捨てで，一分以内の誤差がある

# スケジュールの確認：
#  date --date @$(head -1 /run/systemd/shutdown/scheduled |cut -c6-15)

if [ $# != 2 ] && [ $# != 0 ]; then
	echo Error: $*
	exit 1
fi

if [ $# -eq 0 ]; then
	echo -n "DATE (ex. YY-MM-DD) >> "
	read day
	echo -n "TIME (ex. hh:mm:ss) >> "
	read time
else
	day=$1
	time=$2
fi

sudo shutdown -h +$(expr \( `date -d"${day} ${time}" +%s` - `date -d"now" +%s` \) / 60)
#echo $(expr \( `date -d"${day} ${time}" +%s` - `date -d"now" +%s` \) / 60)


