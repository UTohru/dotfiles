#!/usr/bin/env bash

# if [ $# != 1 ]; then
# 	echo Error: $*
# 	exit 1
# fi

pacmd list-sinks | grep -e 'name:' -e 'index:'

echo "=== command ===="
echo "pacmd set-default-sink <index>"
