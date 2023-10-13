bindkey '^K' menu-select
bindkey '^J' menu-select
bindkey -M menuselect '^K' vi-up-line-or-history
bindkey -M menuselect '^J' vi-down-line-or-history
bindkey -M menuselect '^L' vi-forward-char
bindkey -M menuselect '^H' vi-backward-char

# bindkey '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

bindkey -M menuselect '\r' .accept-line

#zstyle ':completion:list-expand:*' completer _expand _complete _ignored
zstyle ':completion:*:paths' path-completion yes
