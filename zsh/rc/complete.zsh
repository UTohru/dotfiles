autoload -Uz compinit && compinit
zstyle ':completion:*' verbose yes


# そのまま探す -> 小文字を大文字に変えて探す -> 大文字を小文字に変えて探す
#zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'
# 小文字だけなら大文字も
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

# 補完方法毎にグループ化
#zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''


## 補完候補を一覧から選択する．補完候補が2つ以上なければすぐに補完する．
zstyle ':completion:*:default' menu select=2
