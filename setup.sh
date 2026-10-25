#!/bin/bash
set -e

cdir="$(realpath "$(dirname "$0")")"

# ===============
# ignore localconf
# ===============
ignore_list=("${cdir}/.config/zsh/localconf/rc.zsh" "${cdir}/.config/zsh/localconf/profile.zsh" "${cdir}/.config/i3/enable/local.conf" "${cdir}/.config/sway/enable/local.conf" "${cdir}/.config/hypr/local.conf")
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
ln -sf ${cdir}/_shell/dircolors ~/.dircolors

ln -sf ${cdir}/others/.textlintrc ~/.textlintrc
if [ ! -d ~/.local/share/deno_ts ]; then
	mkdir -p ~/.local/share/deno_ts
fi
ln -sf ${cdir}/others/textlint.ts ~/.local/share/deno_ts/textlint.ts

ln -sf ${cdir}/.xprofile ~/.xprofile


# ===============
# wsl (ubuntu)
# ===============
if [[ -d /run/WSL ]]; then
	mkdir -p ~/.local/bin ~/.config/zsh/localconf
	if command -V powershell.exe > /dev/null 2>&1; then
		WIN_USERDIR=$(wslpath -ua "$(powershell.exe '$env:USERPROFILE' | tr -d '\r\n')")
		if [ ! -L ~/desktop ]; then
			ln -sf "${WIN_USERDIR}/Desktop" ~/desktop
		fi
		grep -q '^export WIN_USER=' ~/.config/zsh/localconf/profile.zsh 2>/dev/null \
			|| echo "export WIN_USER=${WIN_USERDIR##*/}" >> ~/.config/zsh/localconf/profile.zsh
	fi
	grep -q '^export NPM_CONFIG_PREFIX=' ~/.config/zsh/localconf/profile.zsh 2>/dev/null \
		|| echo 'export NPM_CONFIG_PREFIX="$HOME/.local"' >> ~/.config/zsh/localconf/profile.zsh

	sudo apt -y install language-pack-ja manpages-ja manpages-ja-dev
	sudo update-locale LANG=ja_JP.UTF8
	{
		echo -e "[interop]\nappendWindowsPath = false"
		echo -e "[boot]\nsystemd = true"
	} | sudo tee /etc/wsl.conf >/dev/null
	echo "set bell-style none" > ~/.inputrc

	ln -sf /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ~/.local/bin/powershell.exe
	ln -sf /mnt/c/Windows/System32/cmd.exe ~/.local/bin/cmd.exe
	ln -sf /mnt/c/Windows/explorer.exe ~/.local/bin/explorer.exe
	ln -sf /mnt/c/Windows/System32/clip.exe ~/.local/bin/clip.exe

	ZSH="$(command -v zsh 2>/dev/null || true)"
	if [[ -n "${ZSH}" && "${SHELL}" != "${ZSH}" ]]; then
		grep -qxF "${ZSH}" /etc/shells || echo "${ZSH}" | sudo tee -a /etc/shells
		chsh -s "${ZSH}"
	fi
fi

echo "complete!"
