
source ${ZDOTDIR}/localconf/profile.zsh

# about ssh
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then 
	if [ -d "$HOME/.local/bin" ] ; then
		PATH="$HOME/.local/bin:$PATH"
	fi
	if [ -d "$HOME/bin" ] ; then
		PATH="$HOME/bin:$PATH"
	fi
fi

# if [ -n "$DESKTOP_SESSION" ]; then 
# fi

if [ -z "${SSH_AUTH_SOCK}" ]; then 
	if [ -r "/run/user/$(id -u)/keyring/ssh" ]; then
		# Already Started
		export SSH_AUTH_SOCK="/run/user/$(id -u)/keyring/ssh"
	else
		# gnome-keyring
		if command -V gnome-keyring-daemon > /dev/null 2>&1; then
			eval $(gnome-keyring-daemon --start) #--components=ssh,secrets)
			export SSH_AUTH_SOCK
		fi
	fi
fi

if command -V firefox > /dev/null 2>&1; then
	export BROWSER=`which firefox`
fi

