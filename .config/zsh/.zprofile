
source ${ZDOTDIR}/localconf/profile.zsh

dotdir=$(cd $(dirname $(dirname $(readlink -f ${ZDOTDIR}))); pwd)
source ${dotdir}/_shell/profile
