#!/bin/bash
set -e

# ===============
#
# Mainly create symbolic link
#
# ===============

cdir="$(cd "$(dirname "$(readlink -e "$0" || echo "$0")")"; pwd -P)"

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
	vim_version=$(vim --version | head -n 1 | grep -o -E "[0-9]+\.[0-9]")
	vim_version_check=$(echo "scale=2;$vim_version >= 9.0" | bc)
	if [ $vim_version_check -eq 1 ]; then
		# deno install
		if ! builtin command -V deno > /dev/null 2>&1; then
			curl -fsSL https://deno.land/x/install/install.sh | sh
		fi
	fi

	if [ -d ~/.vim ]; then
		rm -rf ~/.vim
	fi
	ln -sf ${cdir}/vim ~/.vim
	ln -sf ${cdir}/.vimrc ~/.vimrc
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

if [ -d ~/.mlterm ]; then
	rm -rf ~/.mlterm
fi
ln -sf ${cdir}/mlterm ~/.mlterm

ln -sf ${cdir}/.tmux.conf ~/.tmux.conf
ln -sf ${cdir}/.latexmkrc ~/.latexmkrc

ln -sf ${cdir}/.zshenv ~/.zshenv

ln -sf ${cdir}/.textlintrc ~/.textlintrc

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
