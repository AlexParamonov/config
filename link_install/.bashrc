# If not running interactively, don't do anything
[ -z "$PS1" ] && return

BASH_USER_CONFIGS=~/.bash

source $BASH_USER_CONFIGS/env.sh
source $BASH_USER_CONFIGS/colors.sh
source $BASH_USER_CONFIGS/config.sh
source $BASH_USER_CONFIGS/promt.sh
source $BASH_USER_CONFIGS/extra.sh
source $BASH_USER_CONFIGS/aliases.sh
source $BASH_USER_CONFIGS/completion.sh
