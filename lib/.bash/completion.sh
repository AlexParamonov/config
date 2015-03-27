# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# git flow completion
source $BASH_USER_CONFIGS/vendor/git-flow-completion.sh
source $BASH_USER_CONFIGS/vendor/hub.bash_completion.sh
