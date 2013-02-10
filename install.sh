#!/bin/bash

for config in `ls -1A | grep -E "^\." | grep -v -E "(\.rvm|\.local|\.ssh|\.git|\.gitignore|\.gitmodules)$"`
do
  echo "installing $config"
  rm -r "$HOME/$config" 2> /dev/null
  ln -s "`pwd`/$config" "$HOME/$config"
done

echo "Applying default VIM environment"
cp "$HOME/.vim/.vimrc-environment.default.vim" "$HOME/.vim/.vimrc-environment.vim"
echo "Load VIM plugins"
vim -c BundleInstall! -c q -c q -u "$HOME/.vim/.vimrc-bundles.vim"

echo "Done."

# echo
# echo "Updating fonts..."
# echo `fc-cache -fv | grep "fc-cache"`

echo
echo "================================================="
echo "  WARNING! Install .ssh, .rvm, .local manually."
echo "================================================="
