#!/bin/bash

for config in `ls -1A | grep -v -E "(install.sh|.rvm|.local|.ssh|.git|.gitignore)$"`
do
  echo "installing $config"
  rm "$HOME/$config"
  ln -s "`pwd`/$config" "$HOME/$config"
done

echo "Done."

echo
echo "Updating fonts..."
echo `fc-cache -fv | grep "fc-cache"`

eval `dircolors ~/.dircolors`

echo
echo "================================================="
echo "  WARNING! Install .ssh, .rvm, .local manually."
echo "================================================="
