#!/bin/bash
set -e

# ===============
# Mainly create symbolic link
# ===============

cdir="$(realpath "$(dirname "$0")")"

# ===============
# required check in this
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
ignore_list=("${cdir}/.config/zsh/localconf/rc.zsh" "${cdir}/.config/zsh/localconf/profile.zsh" "${cdir}/.config/i3/enable/local.conf" "${cdir}/.config/sway/enable/local.conf")
git update-index --skip-worktree ${ignore_list[@]}


# ===============
# vim
# ===============
if [ -x "$(command -v vim)" ]; then
	if [ -d ~/.vim ]; then
		rm -rf ~/.vim
	fi
	ln -sf ${cdir}/vim ~/.vim
	ln -sf ${cdir}/.vimrc ~/.vimrc
fi

# deno
if [ ! -x "$(command -v deno)" ]; then
	deno_confirm="Do you install deno? (needed for vim-plugins) [Y/n]:"
	while true; do
		echo -n "${deno_confirm}"
		read Ans
		case $Ans in
			[Yy]*)
				curl -fsSL https://deno.land/install.sh | sh
				break
				;;
			[Nn]*)
				break
				;;
			*)
				;;
		esac
	done
fi


# ===============
# config links
# ===============

function ln_config() {
	if [ ! -d ~/.config ]; then
		mkdir ~/.config
	fi
	for path in "${cdir}"/.config/*
	do
		src="$(basename "${path}")"
		if [ -d ~/.config/"${src}" ]; then
			rm -rf ~/.config/"${src}"
		fi
		ln -sf "${path}" ~/.config/"${src}"
	done
}

ln_config

if [ ! -d ${cdir}/.config/i3/wallpaper ]; then
	mkdir ${cdir}/.config/i3/wallpaper
fi

# ===============
# other links
# ===============
ln -sf ${cdir}/.zshenv ~/.zshenv

ln -sf ${cdir}/others/.textlintrc ~/.textlintrc
if [ ! -d ~/.local/share/deno_ts ]; then
	mkdir -p ~/.local/share/deno_ts
fi
ln -sf ${cdir}/others/textlint.ts ~/.local/share/deno_ts/textlint.ts

ln -sf ${cdir}/.xprofile ~/.xprofile


# ===============
# wsl (ubuntu)
# ===============
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	if command -V powershell.exe > /dev/null 2>&1; then
		WIN_USERDIR=$(wslpath -ua $(powershell.exe '$env:USERPROFILE' | sed -e 's/[\r\n]\+//g'))
		if [ ! -L $HOME/desktop ]; then
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
	ln -sf /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe $HOME/.local/bin/powershell.exe
	ln -sf /mnt/c/Windows/System32/cmd.exe $HOME/.local/bin/cmd.exe
	ln -sf /mnt/c/Windows/explorer.exe $HOME/.local/bin/explorer.exe
fi

# ===============
# install font
# ===============
confirm_message="Do you install font? [Y/n]:"
if [ ! -d ~/.local/share/fonts/Firge ]; then
while true; do
	echo -n "${confirm_message}"
	read Ans
	case $Ans in
		[Yy]*)
			# if [ ! -d ~/.local/share/fonts/Cica ]; then
			# 	cd /tmp
			# 	mkdir -p ~/.local/share/fonts/Cica

			# 	curl https://api.github.com/repos/miiton/Cica/releases/latest | jq '.assets[0].browser_download_url' | xargs curl -L -o /tmp/Cica.zip
			# 	unzip -o Cica.zip -d ~/.local/share/fonts/Cica
			# 	fc-cache -fv
			# fi
			if [ ! -d ~/.local/share/fonts/Firge ]; then
				cd /tmp
				mkdir -p ~/.local/share/fonts/Firge
			
				curl https://api.github.com/repos/yuru7/Firge/releases/latest | jq '.assets[0].browser_download_url' | xargs curl -L -o /tmp/Firge.zip
				unzip -j -o Firge.zip -d ~/.local/share/fonts/Firge
			fi
			break
			;;
		[Nn]*)
			break
			;;
		*)
			;;
	esac
done
fi

echo "complete!"
