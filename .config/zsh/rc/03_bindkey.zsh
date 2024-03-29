bindkey -v # vi
#bindkey -e # 

# move
bindkey "^H" backward-word
bindkey "^L" forward-word # use clear command

# delete word
bindkey "^[[3;5~" delete-word # ctrl + delete

# history search
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end


# single command
function fzf-select-dirs() {
	local lbuf pref search_dir fd_arg
	pref="${LBUFFER##* }"
	pref="${pref/#\~/"${HOME}"}"
	lbuf="${LBUFFER% *}"
	if [ -d "${pref}" ]; then
		search_dir="${pref}"
	else
		search_dir="$(realpath -m "$(dirname "${pref:-"."}")")"
	fi

	if [ -d "${search_dir}" ]; then
		fd_arg="--type d --hidden -p --exclude .git ${search_dir} --search-path ${search_dir}"
		pref="$(basename ${pref})"
	else
		fd_arg="--type d --hidden -p --exclude .git ${pref}"
	fi
	BUFFER="${lbuf} $(fd ${=fd_arg} | fzf --height 70% --layout reverse --query=${pref})" && zle accept-line
	CURSOR=$#BUFFER
	zle reset-prompt
}
zle -N fzf-select-dirs
bindkey '^[[Z' fzf-select-dirs


# comp single enter
zmodload -i zsh/complist
bindkey -M menuselect '^M' .accept-line
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
# bindkey -M menuselect '\r' .accept-line
