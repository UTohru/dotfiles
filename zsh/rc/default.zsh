
#################################  BASE  #################################
# history
HISTFILE=$HOME/.zsh-history # 履歴を保存するファイル
SAVEHIST=10000 # ファイルに保存する履歴のサイズ
HISTSIZE=2000 # メモリ上に保存する履歴のサイズ

autoload -Uz add-zsh-hook
autoload -Uz colors && colors

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    #alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
