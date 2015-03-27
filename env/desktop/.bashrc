# If not running interactively, don't do anything
[ -z "$PS1" ] && return

BASH_USER_CONFIGS=~/.bash

source $BASH_USER_CONFIGS/env/desktop.sh
source $BASH_USER_CONFIGS/color_table.sh
source $BASH_USER_CONFIGS/color_setup.sh
source $BASH_USER_CONFIGS/config.sh
source $BASH_USER_CONFIGS/ruby_tweaks.sh
source $BASH_USER_CONFIGS/promt.sh
source $BASH_USER_CONFIGS/aliases.sh
source $BASH_USER_CONFIGS/completion.sh
# source $BASH_USER_CONFIGS/rbenv.sh
source $BASH_USER_CONFIGS/rvm.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

fortune
echo

source ~/.nvm/nvm.sh
# export NVM_DIR="/home/ap/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
