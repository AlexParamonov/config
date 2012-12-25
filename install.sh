#!/bin/bash

for config in `ls -1A | grep -E "^\." | grep -v -E "(\.rvm|\.local|\.ssh|\.git|\.gitignore|\.gitmodules)$"`
do
  echo "installing $config"
  rm -r "$HOME/$config" 2> /dev/null
  ln -s "`pwd`/$config" "$HOME/$config"
done

echo "Done."

# echo
# echo "Updating fonts..."
# echo `fc-cache -fv | grep "fc-cache"`

echo
echo "================================================="
echo "  WARNING! Install .ssh, .rvm, .local manually."
echo "================================================="
