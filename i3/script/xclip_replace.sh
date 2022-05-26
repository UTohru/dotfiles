#!/usr/bin/env bash

# echo で改行が消える
text="$(echo $(xclip -o))"

echo "${text//- /}" | xclip -i
