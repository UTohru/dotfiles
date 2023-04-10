
#################################  BASE  #################################
# history
HISTFILE=$HOME/.zsh-history # 履歴を保存するファイル
SAVEHIST=10000 # ファイルに保存する履歴のサイズ
HISTSIZE=2000 # メモリ上に保存する履歴のサイズ

autoload -Uz add-zsh-hook

autoload -Uz colors && colors
# if builtin command -v dircolors > /dev/null 2>&1 && [ -f "$ZDOTDIR/dircolors" ]; then
# 	eval $(dircolors "$ZDOTDIR/dircolors")
# 	export USER_LS_COLORS=$LS_COLORS
# fi

