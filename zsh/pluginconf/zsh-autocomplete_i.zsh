zstyle ':autocomplete:*' default-context ''
zstyle ':autocomplete:*' min-delay 0.05
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' ignored-input ''

zstyle -e ':autocomplete:list-choices:*' list-lines 'reply=( $(( LINES / 2 )) )'
zstyle ':autocomplete:history-search:*' list-lines 10
zstyle ':autocomplete:*' insert-unambiguous no
zstyle ':autocomplete:tab:*' fzf-completion yes


# zstyle ':autocomplete:*' widget-style menu-select

zstyle ':completion:*:' group-order \
	expansions options \
	executables local-directories directories \
	aliases functions builtins reserved-words commands


autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit
else
	compinit -C
fi
