
#################################  PROMPT  #################################



# git
autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null
setopt prompt_subst


function rprompt-git-current-branch {
  local name st color gitdir action
  if [[ "$PWD" =~ /\.git(/.*)?$ ]]; then
    return
  fi
  name=$(git symbolic-ref HEAD 2> /dev/null)
  name=${name##refs/heads/}
  if [[ -z $name ]]; then
    return
  fi

  gitdir=$(git rev-parse --git-dir 2> /dev/null)
  # U+E725 : git branch
  action=$(VCS_INFO_git_getaction "$gitdir") && action="($action)"

  st=$(git status 2> /dev/null)
  if echo "$st" | grep -q "^nothing to"; then
    color=%F{green}
  elif echo "$st" | grep -q "^nothing added"; then
    color=%F{yellow}
  elif echo "$st" | grep -q "^# Untracked"; then
    color=%B%F{red}
  else
    color=%F{red}
  fi
  #echo "$color(%1{\UE725%}$name$action)%f%b"
  echo "$color($name$action)%f%b"
}

# get return code 
function __show_status() {
  exit_status=${pipestatus[*]}
  local SETCOLOR_DEFAULT="%f"
  local SETCOLOR=${SETCOLOR_DEFAULT}
  local s
  for s in $(echo -en "${exit_status}"); do
    if [ "${s}" -eq 147 ] ; then
      SETCOLOR=${SETCOLOR_DEFAULT}
      break
    elif [ "${s}" -gt 100 ] ; then
      SETCOLOR="%F{red}"
      break
    elif [ "${s}" -gt 0 ] ; then
      SETCOLOR="%F{yellow}"
    fi
  done
  if [ "${SETCOLOR}" != "${SETCOLOR_DEFAULT}" ]; then
    echo -ne "${SETCOLOR}<${exit_status// /|}>%f%b"
  else
    echo -ne "${SETCOLOR}%f%b"
  fi
}

# if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then 
# 	HOST_COLOR='magenta'
# else
# 	HOST_COLOR='cyan'
# fi

# == left PROMPT ==
## default version
# PROMPT='%{%F{green}%}%n %{%F{$HOST_COLOR}%}%m%{%F{white}%}[%.$(rprompt-git-current-branch)]$(__show_status): '
## select icon wides version
# PROMPT='%{%F{green}%}%1{'$'\UF2be''%} %n %{%F{$HOST_COLOR}%}%1{'$'\UF108''%} %m%{%F{white}%}[%.$(rprompt-git-current-branch)]$(__show_status)%# '

## no-icon short version
PROMPT='%.$(rprompt-git-current-branch)$(__show_status) : '




