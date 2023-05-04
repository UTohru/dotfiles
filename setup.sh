#!/bin/bash
set -e

# ===============
#
# Mainly create symbolic link
#
# ===============

cdir=$(cd $(dirname $0);pwd)

# ===============
# required check
# ===============
package_list=("curl" "unzip" "bc" "jq")
not_exist_package=()
for p in "${package_list[@]}"
do
	if ! builtin command -V $p > /dev/null 2>&1; then
		not_exist_package+=($p)
	fi
done

if [ ${#not_exist_package[@]} != 0 ]; then
	echo "[ ${not_exist_package[@]} ] these packages are required"
	exit 127
fi

# ===============
# ignore localconf
# ===============
ignore_list=("${cdir}/zsh/localconf/rc.zsh" "${cdir}/zsh/localconf/profile.zsh" "${cdir}/i3/enable/local.conf" "${cdir}/sway/enable/local.conf")
git update-index --skip-worktree ${ignore_list[@]}


# ===============
# vim
# ===============
if [ -x "$(command -v vim)" ]; then
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
		echo "Configure \"mini-vimrc\" without plugins\n"
		ln -sf ${cdir}/others/mini-vimrc ~/.vimrc
	fi
fi


# ===============
# other links
# ===============

if [ -d ~/.mlterm ]; then
	rm -rf ~/.mlterm
fi
ln -sf ${cdir}/mlterm ~/.mlterm

ln -sf ${cdir}/.tmux.conf ~/.tmux.conf
ln -sf ${cdir}/.latexmkrc ~/.latexmkrc

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


if [ ! -d ~/.config ]; then
	mkdir ~/.config
fi

if [ ! -d ${cdir}/i3/wallpaper ]; then
	mkdir ${cdir}/i3/wallpaper
fi
if [ ! -d ${cdir}/sway/wallpaper ]; then
	ln -s ${cdir}/i3/wallpaper ${cdir}/sway/wallpaper
fi

# ===============
# x or wayland
# ===============

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
	if [ -d ~/.config/sway ]; then
		rm -rf ~/.config/sway
	fi
	ln -sf ${cdir}/sway ~/.config/sway
	ln -sf ${cdir}/i3/available/sway_input.conf ~/.config/sway/enable/sway_input.conf

	if [ ! -d ~/.config/environment.d ]; then
		mkdir ~/.config/environment.d
	fi
	
	if [ -f ~/.config/environment.d/wayland.conf ]; then
		rm ~/.config/environment.d/wayland.conf
	fi
	ln -s ${cdir}/others/systemd_env_sway.conf ~/.config/environment.d/wayland.conf

	# exportを削除してコピー
	# oldifs=$IFS
	# IFS=''
	# while read line; do
	# 	if [ "${line% *}" = "export" ]; then
	# 		echo ${line#* } >> ~/.config/environment.d/wayland.conf
	# 	fi
	# done < ${cdir}/.xprofile
	# IFS=$oldifs

	# sudo cp ${cdir}/others/Wsession /etc/lightdm/
else
	if [ -d ~/.config/i3 ]; then
		rm -rf ~/.config/i3
	fi
	ln -sf ${cdir}/i3 ~/.config/i3
	ln -sf ${cdir}/compton.conf ~/.config/compton.conf
	ln -sf ${cdir}/.xprofile ~/.xprofile
fi




# ===============
# wsl (ubuntu)
# ===============
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	if command -V powershell.exe > /dev/null 2>&1; then
		WIN_USERDIR=$(wslpath -ua $(powershell.exe '$env:USERPROFILE' | sed -e 's/[\r\n]\+//g'))
		if [ ! -f $HOME/desktop ]; then
			ln -sf $WIN_USERDIR/Desktop ~/desktop
		fi
		echo "export WIN_USER=${WIN_USERDIR##*/}" >> ~/.config/zsh/localconf/profile.zsh
	fi
	sudo apt -y install language-pack-ja manpages-ja manpages-ja-dev
	sudo update-locale LANG=ja_JP.UTF8
	echo -e "[interop]\nappendWindowsPath = false" | sudo tee /etc/wsl.conf >/dev/null
	echo "set bell-style none" > ~/.inputrc

	if [ ! -d ~/.local/bin ]; then
		mkdir -p ~/.local/bin
	fi
	ln -s /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe $HOME/.local/bin/powershell.exe
	ln -s /mnt/c/Windows/System32/cmd.exe $HOME/.local/bin/cmd.exe
	ln -s /mnt/c/Windows/explorer.exe $HOME/.local/bin/explorer.exe
else
	# ===============
	# install Cica font
	# ===============
	if [ ! -d ~/.local/share/fonts/Cica ]; then
		mkdir -p ~/.local/share/fonts/Cica

		cd /tmp
		curl https://api.github.com/repos/miiton/Cica/releases/latest | jq '.assets[0].browser_download_url' | xargs curl -L -o /tmp/Cica.zip
		unzip -o Cica.zip -d ~/.local/share/fonts/Cica
		fc-cache -fv
	fi
fi
