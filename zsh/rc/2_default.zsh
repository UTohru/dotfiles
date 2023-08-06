#################################  BASE  #################################
HISTFILE=$HOME/.zsh-history 
SAVEHIST=10000 # in file
HISTSIZE=2000 # in memory

autoload -Uz add-zsh-hook

autoload -Uz colors && colors
# if builtin command -v dircolors > /dev/null 2>&1 && [ -f "$ZDOTDIR/dircolors" ]; then
# 	eval $(dircolors "$ZDOTDIR/dircolors")
# 	export USER_LS_COLORS=$LS_COLORS
# fi

