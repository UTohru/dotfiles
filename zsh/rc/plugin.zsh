
ZPLGDIR="$ZDATADIR/zinit"

###
# zinit setup
###

if ! test -d "$ZPLGDIR"; then
	mkdir -p "$ZPLGDIR"
	chmod g-rwx "$ZPLGDIR"
	git clone --depth 5 https://github.com/zdharma-continuum/zinit.git ${ZPLGDIR}/bin
fi

typeset -gAH ZPLGM
ZPLGM[HOME_DIR]="${ZPLGDIR}"
source "$ZPLGDIR/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


###
# plugin load
###

zinit light-mode for \
	@zdharma-continuum/zinit-annex-readurl
#	@zinit-zsh/z-

# == sample ==
# zinit wait'0' lucid \
# 	atinit"source $ZDOTDIR/pluginconfig/script_i.zsh"
# 	atload"source $ZDOTDIR/pluginconfig/script_l.zsh"
# 	light-mode for @hoge/plugin

zinit wait'0b' lucid \
	atload"source $ZDOTDIR/pluginconf/zsh-autosuggestions_l.zsh" \
	light-mode for @zsh-users/zsh-autosuggestions

# zinit wait'0a' lucid \
# 	atinit"source $ZDOTDIR/pluginconf/zsh-autocomplete_i.zsh" \
# 	light-mode for @marlonrichert/zsh-autocomplete



# zinit wait'1a' lucid \
# 	from"gh-r" as"program" pick"bin/exa" \
# 	atload"source $ZDOTDIR/pluginconf/exa_l.zsh" \
# 	light-mode for @ogham/exa

# zinit wait'1b' lucid \
# 	light-mode for @chitoku-k/fzf-zsh-completions
