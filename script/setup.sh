#!/bin/sh
set -eo pipefail

#
# Mainly create symbolic link
#

cdir=$(cd $(dirname $0);cd ..;pwd)

# restrict  git add localconf
ln -s ${cdir}/others/pre-commit ${cdir}/.git/hooks/

# vim
vim_version=$(vim --version | head -n 1 | grep -o -E "[0-9]+\.[0-9]")
vim_version_check=$(echo "scale=2;$vim_version >= 8.2" | bc)
if [ $vim_version_check -eq 1 ]; then
	# deno install
	if ! builtin command -V deno > /dev/null 2>&1; then
		curl -fsSL https://deno.land/x/install/install.sh | sh
	fi

	if [ -d ~/.vim ]; then
		rm -rf ~/.vim
	fi
	ln -sf ${cdir}/vim ~/.vim
	ln -sf ${cdir}/.vimrc ~/.vimrc
else
	echo "[warning] vim version is too low"
	echo "Configure <mini-vimrc> without plugins\n"
	ln -sf ${cdir}/others/mini-vimrc ~/.vimrc
fi


if [ -d ~/.mlterm ]; then
	rm -rf ~/.mlterm
fi
ln -sf ${cdir}/mlterm ~/.mlterm

ln -sf ${cdir}/.tmux.conf ~/.tmux.conf
ln -sf ${cdir}/.latexmkrc ~/.latexmkrc
ln -sf ${cdir}/.xprofile ~/.xprofile

if [ -d ~/.config/i3 ]; then
	rm -rf ~/.config/i3
fi
ln -sf ${cdir}/i3 ~/.config/i3
if [ ! -d ~/.config/i3/wallpaper ]; then
	mkdir ~/.config/i3/wallpaper
fi
ln -sf ${cdir}/compton.conf ~/.config/compton.conf


ln -sf ${cdir}/.zshenv ~/.zshenv
if [ -d ~/.config/zsh ]; then
	rm -rf ~/.config/zsh
fi
ln -sf ${cdir}/zsh ~/.config/zsh



if [ -d ~/.config/wezterm ]; then
	rm -rf ~/.config/wezterm
fi
ln -sf ${cdir}/wezterm ~/.config/wezterm

