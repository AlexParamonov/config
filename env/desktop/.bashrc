# If not running interactively, don't do anything
[ -z "$PS1" ] && return

BASH_USER_CONFIGS=~/.bash

source $BASH_USER_CONFIGS/env/base.sh
source $BASH_USER_CONFIGS/color_table.sh
source $BASH_USER_CONFIGS/color_setup.sh
# source $BASH_USER_CONFIGS/rbenv.sh
source $BASH_USER_CONFIGS/config.sh
source $BASH_USER_CONFIGS/ruby_tweaks.sh
source $BASH_USER_CONFIGS/promt.sh
source $BASH_USER_CONFIGS/aliases.sh
source $BASH_USER_CONFIGS/completion.sh
# source $BASH_USER_CONFIGS/vault.sh
# source $BASH_USER_CONFIGS/rvm.sh
source $BASH_USER_CONFIGS/asdf.sh
source $BASH_USER_CONFIGS/elixir.sh
source $BASH_USER_CONFIGS/eb.sh
source $BASH_USER_CONFIGS/python.sh
source $BASH_USER_CONFIGS/yarn.sh
source $BASH_USER_CONFIGS/fzf.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# source ~/.nvm/nvm.sh
source ~/.vim/plugged/gruvbox/gruvbox_256palette.sh
# export NVM_DIR="/home/ap/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

source $BASH_USER_CONFIGS/env/desktop.sh

eval "$(direnv hook bash)"

clear
