autoload -Uz compinit && compinit

#
# :completion:<function>:<completer>:<command>:<argument>:<tag>
#

zstyle ':completion:*' verbose yes


zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

zstyle ':completion:*' format '%B%F{yellow}[%d] %f%b'
zstyle ':completion:*' group-name ''


if [ -n "$LS_COLORS" ]; then
	zstyle ':completion:*' list-colors $LS_COLORS
fi


zstyle ':completion:*:default' menu select=2


zstyle ':completion:*:processes' command 'ps x -o pid,user,s,args'


zstyle ':completion:*' file-patterns '
    *(D-/):directories:"directory"
    ^*.(D-^/*):files:"file"
'
zstyle ':completion:*:*:vim:*:*' group-order files directory

zstyle ':completion:*:*:evince:*' file-patterns '*.pdf(D-^/*):pdf-files:"PDF" *(D-/):directories:"directory"'
zstyle ':completion:*:*:(latexmk|uplatex|platex):*' file-patterns '*.tex(D-^/*):tex-files:"TEX" *(D-/):directories:"directory"'


if [ -r ~/.ssh/config ]; then
	h=($h ${${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*}% *})
fi
zstyle ':completion:*:*:(ssh|sftp|rsync):*:hosts' hosts $h
# zstyle ':completion:*:*:(ssh|sftp|rsync):*:hosts' ignored-patterns loopback ip6-loopback ip6-localhost bloadcast localhost

zstyle ':completion:*' use-cache true
