
source ${ZDOTDIR}/localconf/profile.zsh

dotdir=$(cd $(dirname $(readlink -f ${ZDOTDIR})); pwd)
source ${dotdir}/_shell/profile
