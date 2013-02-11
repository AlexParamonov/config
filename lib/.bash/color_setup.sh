# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r $BASH_USER_CONFIGS/vendor/.dircolors && eval "$(dircolors -b $BASH_USER_CONFIGS/vendor/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

