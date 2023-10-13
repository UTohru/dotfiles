
source ${ZDOTDIR}/localconf/rc.zsh

for f (${ZDOTDIR}/rc/*.zsh) source $f

typeset -U path PATH
