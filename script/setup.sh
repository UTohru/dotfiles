#!/bin/bash
set -e

#
# Mainly create symbolic link
#

cdir=$(cd $(dirname $0);cd ..;pwd)

#
# ignore localconf
# 
ignore_list=("${cdir}/zsh/localconf/rc.zsh" "${cdir}/zsh/localconf/profile.zsh" "${cdir}/i3/enable/local.conf")
git update-index --skip-worktree ${ignore_list[@]}

#
# vim
#
vim_version=$(vim --version | head -n 1 | grep -o -E "[0-9]+\.[0-9]")
vim_version_check=$(echo "scale=2;$vim_version >= 8.2" | bc)
if [ $vim_version_check -eq 1 ]; then
	# deno install
	if ! builtin command -V deno > /dev/null 2>&1; then
		curl -fsSL https://deno.land/x/install/install.sh | sh
		echo "export DENO_INSTALL=/home/$USER/.deno" >> ~/dotfiles/zsh/localconf/rc.zsh
		echo "export PATH=\"$DENO_INSTALL/bin:$PATH\"" >> ~/dotfiles/zsh/localconf/rc.zsh
	fi

	if [ -d ~/.vim ]; then
		rm -rf ~/.vim
	fi
	ln -sf ${cdir}/vim ~/.vim
	ln -sf ${cdir}/.vimrc ~/.vimrc
else
	echo "[warning] vim version is too low"
	echo "Configure \"mini-vimrc\" without plugins\n"
	ln -sf ${cdir}/others/mini-vimrc ~/.vimrc
fi


if [ -d ~/.mlterm ]; then
	rm -rf ~/.mlterm
fi
ln -sf ${cdir}/mlterm ~/.mlterm

ln -sf ${cdir}/.tmux.conf ~/.tmux.conf
ln -sf ${cdir}/.latexmkrc ~/.latexmkrc

if [ ! -d ~/.config ]; then
	mkdir ~/.config
fi

if [ ! -d ${cdir}/i3/wallpaper ]; then
	mkdir ${cdir}/i3/wallpaper
	if [ ! -d ${cdir}/sway/wallpaper ]; then
		ln -s ${cdir}/i3/wallpaper ~/.config/sway/wallpaper
	fi
fi

#
# x or wayland
# 

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
	if [ -d ~/.config/sway ]; then
		rm -rf ~/.config/sway
	fi
	ln -sf ${cdir}/sway ~/.config/sway
	ln -sf ${cdir}/i3/available/sway_input.conf ~/.config/sway/enable/sway_input.conf

	if [ ! -d ~/.config/environment.d ]; then
		mkdir ~/.config/environment.d
	fi
	# ln -sf ${cdir}/.xprofile ~/.pam_environment
	
	ln -sf ${cdir}/.xprofile ~/.config/environment.d/wayland.conf
else
	if [ -d ~/.config/i3 ]; then
		rm -rf ~/.config/i3
	fi
	ln -sf ${cdir}/i3 ~/.config/i3
	ln -sf ${cdir}/compton.conf ~/.config/compton.conf
	ln -sf ${cdir}/.xprofile ~/.xprofile
fi


ln -sf ${cdir}/.zshenv ~/.zshenv
if [ -d ~/.config/zsh ]; then
	rm -rf ~/.config/zsh
fi
ln -sf ${cdir}/zsh ~/.config/zsh


if [ -d ~/.config/wezterm ]; then
	rm -rf ~/.config/wezterm
fi
ln -sf ${cdir}/wezterm ~/.config/wezterm

if [ -d ~/.config/efm-langserver ]; then
	rm -rf ~/.config/efm-langserver
fi
ln -sf ${cdir}/efm-langserver ~/.config/efm-langserver

# === wsl (ubuntu) ===
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	if command -V powershell.exe > /dev/null 2>&1; then
		WIN_USER=$(powershell.exe '$env:USERNAME' | sed -e 's/[\r\n]\+//g')
		ln -sf /mnt/c/Users/$WIN_USER/Desktop ~/desktop
	fi
	sudo apt -y install language-pack-ja manpages-ja manpages-ja-dev
	sudo update-locale LANG=ja_JP.UTF8
fi
