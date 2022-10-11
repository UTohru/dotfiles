
source ${ZDOTDIR}/localconf/profile.zsh

# about ssh
#if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then 
#fi

# if [ -n "$DESKTOP_SESSION" ]; then 
# fi

if [ -z "${SSH_AUTH_SOCK}" ]; then 
	if [ -r "/run/user/$(id -u)/keyring/ssh" ]; then
		# Already Started
		export SSH_AUTH_SOCK="/run/user/$(id -u)/keyring/ssh"
	else
		# gnome-keyring
		which gnome-keyring-daemon > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			eval $(gnome-keyring-daemon --start) #--components=ssh,secrets)
			export SSH_AUTH_SOCK
		fi
	fi
fi

which firefox > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		export BROWSER=`which firefox`
	fi

