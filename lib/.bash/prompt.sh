function parse_git_branch {
  local branch
  
  # Get branch name or return if not in git repo
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || {
    # Check if we're in detached HEAD state
    branch=$(git rev-parse --short HEAD 2>/dev/null) || return
    branch="detached:$branch"
  }
  
  echo "($branch)"
}

# export PS1="\w$YELLOW\$(parse_git_branch)$NORMAL\$ "

export PS1="\t \w${YELLOW}\$(parse_git_branch)${NORMAL}\$ "
