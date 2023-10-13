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


# comp single enter
zmodload -i zsh/complist
#bindkey -M menuselect '^M' .accept-line
