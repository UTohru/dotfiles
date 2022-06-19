#!/bin/sh

cdir=$(cd $(dirname $0);cd ..;pwd)

ln -s ${cdir}/others/pre-commit ${cdir}/.git/hooks/

if [ -d ~/.vim ]; then
	rm -rf ~/.vim
fi
ln -sf ${cdir}/vim ~/.vim
ln -sf ${cdir}/.vimrc ~/.vimrc

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

if [ -d ~/.config/conky ]; then
	rm -rf ~/.config/conky
fi
ln -sf ${cdir}/conky ~/.config/conky

ln -sf ${cdir}/.zshenv ~/.zshenv
if [ -d ~/.config/zsh ]; then
	rm -rf ~/.config/zsh
fi
ln -sf ${cdir}/zsh ~/.config/zsh



if [ -d ~/.config/wezterm ]; then
	rm -rf ~/.config/wezterm
fi
ln -sf ${cdir}/wezterm ~/.config/wezterm


# ===
# WSL
# ===
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	if [ ! -e ~/.inputrc ]; then
		{
			echo "# ===";
			echo "# wsl conf";
			echo "# ===";
			echo "#export WIN_USER=\$(printenv | grep -m1 /mnt/c/Users | sed -r 's/.*\/c\/Users\/([^\/]+).*/\\\1/')"
			echo "export BROWSER='/mnt/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe\ \$(wslpath -w \${1})'";
			echo "alias chrome='/mnt/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe'";
			echo "alias explorer='explorer.exe .'";
			echo "alias cmd='cmd.exe'";
		} | tee -a ~/.bashrc >> ~/.config/zsh/localconf/rc.zsh

		touch ~/.inputrc
		{
			echo "set bell-style none"
		} >> ~/.inputrc

		#touch /etc/wsl.conf
		#{
		#	echo "[interop]"
		#	echo "appendWindowsPath=false"
		#} >> /etc/wsl.conf
	fi
fi
