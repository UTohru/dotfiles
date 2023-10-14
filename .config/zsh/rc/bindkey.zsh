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


# function fzf-select-files() {
# 	local lbuf pref
# 	pref="${LBUFFER##* }"
# 	lbuf="${LBUFFER% *}"
#
# 	BUFFER="${lbuf} $(fd --type f --hidden -p --exclude .git \'${pref}\' | fzf --height 70% --layout reverse --preview "bat --color=always" --query=${pref})"
# 	CURSOR=$#BUFFER
# 	zle reset-prompt
# }
# zle -N fzf-select-files
# bindkey '^s^f' fzf-select-files
function fzf-select-dirs() {
	local lbuf pref
	pref="${LBUFFER##* }"
	lbuf="${LBUFFER% *}"

	BUFFER="${lbuf} $(fd --type d --hidden -p --exclude .git ${pref} | fzf --height 70% --layout reverse --query=${pref})" && zle accept-line
	CURSOR=$#BUFFER
	zle reset-prompt
}
zle -N fzf-select-dirs
bindkey '^s' fzf-select-dirs


# comp single enter
zmodload -i zsh/complist
bindkey -M menuselect '^M' .accept-line
# bindkey -M menuselect '\r' .accept-line
