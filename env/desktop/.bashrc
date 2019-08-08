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

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# source ~/.nvm/nvm.sh
source ~/.vim/bundle/gruvbox/gruvbox_256palette.sh
# export NVM_DIR="/home/ap/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

source $BASH_USER_CONFIGS/env/desktop.sh

export PATH=~/Library/Python/2.7/bin:$PATH

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f /Users/ap/code/acm-shop-be/node_modules/tabtab/.completions/serverless.bash ] && . /Users/ap/code/acm-shop-be/node_modules/tabtab/.completions/serverless.bash

clear

# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f /Users/ap/code/acm-order-app-be/node_modules/tabtab/.completions/sls.bash ] && . /Users/ap/code/acm-order-app-be/node_modules/tabtab/.completions/sls.bash
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[ -f /Users/ap/code/acm-order-app-be/node_modules/tabtab/.completions/slss.bash ] && . /Users/ap/code/acm-order-app-be/node_modules/tabtab/.completions/slss.bash