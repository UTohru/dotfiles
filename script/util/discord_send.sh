#!/usr/bin/env sh


if [ -z "$DISCORD_TOKEN" ]; then
	echo "sh : tokenが取得できませんでした"
	exit 1
fi
if [ -z "$DISCORD_CH" ]; then
	echo "sh : channelが取得できませんでした"
	exit 1
fi

which curl  > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "curlコマンドが存在しません"
	exit 1
fi

c="${USER}@`hostname -s`からの通知です."
if [ $# != 1 ]; then
	msg=$c
else
	msg="$c\n$1"
fi

curl -X POST -H "Authorization: Bot $DISCORD_TOKEN" -H "Content-type: application/json" -d "{\"content\":\"$msg\"}" https://discordapp.com/api/channels/$DISCORD_CH/messages

