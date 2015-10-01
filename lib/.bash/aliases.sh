alias g="git"
alias gf="git fetch"
alias gp="git push"
alias gpu="git push --set-upstream origin \$(git branch | awk '/^\\* / { print \$2 }')"
alias gpf="git pullff"
alias gs="git status"
alias gl="git l"

alias v="vim"
alias b="bundle"
alias tf="tail -f"
alias gi="gem install"
alias gv="guard --clear -g"
alias work="tmuxinator sofo"
alias rest="~/.tmuxinator/stop_dev_stuff.sh"

# easier cd
alias .='pwd'
alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ack='ack-grep'
alias notes="ack 'TODO|FIXME|XXX|HACK' --ignore-dir=tmp --ignore-dir=log"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=critical -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
