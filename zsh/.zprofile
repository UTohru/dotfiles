
source ${ZDOTDIR}/localconf/profile.zsh

# no ssh
#if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then 
#fi

# ssh
if [ -n "$DESKTOP_SESSION" ]; then 
	# gnome-keyring
	which gnome-keyring-daemon > /dev/null 2>&1
	if [ $? -eq 0 ]; then
			eval $(gnome-keyring-daemon --start) #--components=ssh,secrets)
		export SSH_AUTH_SOCK
	fi
fi
