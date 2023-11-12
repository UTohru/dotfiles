#!/usr/bin/env bash

set -e

package_list=("eza" "fd-find" "ripgrep" "du-dust" "zoxide")
command_list=("eza" "fd" "rg" "dust" "zoxide")

if [ -d "$HOME/.cargo/bin" ]; then
	export PATH="$HOME/.cargo/bin:$PATH"
fi

for ((i=0; i<"${#package_list[@]}"; i++));
do
	if [ ! -x "$(command -v ${command_list[i]})" ]; then
		cargo install "${package_list[i]}"
	fi
done

echo "Done!"
