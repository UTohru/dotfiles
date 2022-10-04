#!/bin/sh

# ===============
# install Cica font
# ===============

if [ ! -d "~/.local/share/fonts/Cica" ]; then
	mkdir -p ~/.local/share/fonts/Cica

	cd /tmp
	curl https://api.github.com/repos/miiton/Cica/releases/latest | jq '.assets[0].browser_download_url' | xargs curl -L -o /tmp/Cica.zip
	unzip -o Cica.zip -d ~/.local/share/fonts/Cica
	fc-cache -fv
fi

