# autoload -Uz compinit && compinit
zstyle ':completion:*' verbose yes


# 小文字だけなら大文字も
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

# 補完方法毎にグループ化
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''


## 補完候補を一覧から選択する．補完候補が2つ以上なければすぐに補完する．
zstyle ':completion:*:default' menu select=2


# ps/kill
zstyle ':completion:*:processes' command 'ps x -o pid,user,s,args'

zstyle ':completion:*' use-cache true
