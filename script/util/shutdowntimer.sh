#!/usr/bin/env bash

# 切り捨てで，一分以内の誤差がある

# スケジュールの確認：
#  date --date @$(head -1 /run/systemd/shutdown/scheduled |cut -c6-15)

if [ $# != 0 ]; then
	echo Error: $*
	exit 1
fi

echo -n "input DATE (ex. YY-MM-DD) >> "
read day
echo -n "input TIME (ex. hh:mm:ss) >> "
read time

day=$1
time=$2

sudo shutdown -h +$(expr \( `date -d"${day} ${time}" +%s` - `date -d"now" +%s` \) / 60)
#echo $(expr \( `date -d"${day} ${time}" +%s` - `date -d"now" +%s` \) / 60)


