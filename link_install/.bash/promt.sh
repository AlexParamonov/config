function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "("${ref#refs/heads/}")"
}

export PS1="\w$YELLOW\$(parse_git_branch)$NORMAL\$ "
