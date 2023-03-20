#!/usr/bin/env bash
set -e

echo $#
if [ $# -gt 1 ]; then
    echo Error: $*
    exit 1
fi

# see /etc/ImageMagick-6/policy.xml

if builtin command -V convert > /dev/null 2>&1; then
    if [ $# -eq 1 ]; then
        convert -quality 90 $1 eps2:${1%.png}.eps
    else
        for fname in *.png; do
            convert -quality 90 $fname eps2:${fname%.png}.eps
        done
    fi
else
    echo "convert command not found"
    exit 1
fi

