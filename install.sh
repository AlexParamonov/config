#!/bin/bash
ENV_DIR=env/

for config in `ls -1A lib`
do
  echo "linking library $config"
  rm -r "$HOME/$config" 2> /dev/null
  ln -s "`pwd`/lib/$config" "$HOME/$config"
done

PS3="Choose available environment: "
options=`ls -1A $ENV_DIR`
select SELECTED_ENV in $options
do
    case $opt in
        *) break;;
    esac
done

while true; do
    read -p "Using $SELECTED_ENV as source. Is this correct? " yn
    case $yn in
        [Yy]* ) echo "--> Perform $SELECTED_ENV environment install."; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

for config in `ls -1A $ENV_DIR$SELECTED_ENV`
do
  echo "linking $config"
  rm -r "$HOME/$config" 2> /dev/null
  ln -s "`pwd`/$ENV_DIR$SELECTED_ENV/$config" "$HOME/$config"
done

echo "Applying default VIM environment"
cp "$HOME/.vim/.vimrc-environment.default.vim" "$HOME/.vim/.vimrc-environment.vim"

while true; do
    read -p "Load VIM plugins now? " yn
    case $yn in
        [Yy]* ) vim -c BundleInstall! -c q -c q -u "$HOME/.vim/.vimrc-bundles.vim"; echo "--> VIM plugins are loaded."; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Installing extra stuff:"
while true; do
    read -p "Update colors in your system to match with VIM colorshema? " yn
    case $yn in
        [Yy]* ) bash "`pwd`/extra/gnome-terminal-colors-solarized/install.sh"; echo "--> Colorshema changed."; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Install custom keyboard layout? " yn
    case $yn in
        [Yy]* ) sudo cp "`pwd`/extra/keyboard_layouts/us" "/usr/share/X11/xkb/symbols/"; echo "--> New layout copied to '/usr/share/X11/xkb/symbols/us'"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Install fonts in your system to match with VIM configuration? " yn
    case $yn in
        [Yy]* ) cp -R "`pwd`/extra/.fonts" "$HOME/" ;echo "Updating fonts..."; echo `fc-cache -fv | grep "fc-cache"`; echo "--> Fonts updated"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Set default rvm gems? " yn
    case $yn in
        [Yy]* ) cp -R "`pwd`/extra/.rvm" "$HOME/" ; echo "--> Default RVM gems installed"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Add VIM app to GNOME like env menus? " yn
    case $yn in
        [Yy]* ) cp -R "`pwd`/extra/.local" "$HOME/" ; echo "--> VIM app is added to menus"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Done."
echo "Have a nice day!"

echo
