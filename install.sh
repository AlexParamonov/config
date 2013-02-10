#!/bin/bash

for config in `ls -1A link_install`
do
  echo "linking $config"
  rm -r "$HOME/$config" 2> /dev/null
  ln -s "`pwd`/link_install/$config" "$HOME/$config"
done

for config in `ls -1A copy_install`
do
  echo "copying $config"
  cp -R "`pwd`/copy_install/$config" "$HOME/"
done

echo "Applying default VIM environment"
cp "$HOME/.vim/.vimrc-environment.default.vim" "$HOME/.vim/.vimrc-environment.vim"


while true; do
    read -p "Install VIM plugins? " yn
    case $yn in
        [Yy]* ) vim -c BundleInstall! -c q -c q -u "$HOME/.vim/.vimrc-bundles.vim"; echo "--> VIM plugins are loaded."; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Update fonts in your system to match with VIM configuration? " yn
    case $yn in
        [Yy]* ) echo "Updating fonts..."; echo `fc-cache -fv | grep "fc-cache"`; echo "--> Fonts updated"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Update colors in your system to match with VIM colorshema? " yn
    case $yn in
        [Yy]* ) bash "`pwd`/manual_install/gnome-terminal-colors-solarized/install.sh"; echo "--> Colorshema changed."; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Install custom keyboard layout? " yn
    case $yn in
        [Yy]* ) sudo cp "`pwd`/manual_install/keyboard_layouts/us" "/usr/share/X11/xkb/symbols/"; echo "--> New layout copied to '/usr/share/X11/xkb/symbols/us'"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Done."
echo "Have a nice day!"

echo
