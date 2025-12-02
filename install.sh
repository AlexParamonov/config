#!/usr/bin/env bash
set -e
shopt -s dotglob nullglob

ENV_DIR="env/"
BASE_ENV="base"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Helper function for yes/no prompts
ask_yes_no() {
    local prompt="$1"
    while true; do
        read -p "$prompt " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Link library configs
for config in $(ls -1A lib); do
    echo "linking library $config"
    rm -rf "$HOME/$config" 2>/dev/null || true
    ln -s "$SCRIPT_DIR/lib/$config" "$HOME/$config"
done

# Select environment
PS3="Choose available environment: "
select SELECTED_ENV in $(ls -1A "$ENV_DIR"); do
    break
done

if ! ask_yes_no "Using $SELECTED_ENV as source. Is this correct?"; then
    exit
fi
echo "--> Perform $SELECTED_ENV environment install."

# Install dependencies
echo "Installing xsel for tmux clipboard support..."
sudo apt-get install -y xsel

# Link base environment configs
for config in $(ls -1A "$ENV_DIR$BASE_ENV"); do
    echo "linking base $config"
    rm -rf "$HOME/$config" 2>/dev/null || true
    ln -s "$SCRIPT_DIR/$ENV_DIR$BASE_ENV/$config" "$HOME/$config"
done

# Link selected environment configs (overrides base)
for config in $(ls -1A "$ENV_DIR$SELECTED_ENV"); do
    echo "linking $SELECTED_ENV $config"
    rm -rf "$HOME/$config" 2>/dev/null || true
    ln -s "$SCRIPT_DIR/$ENV_DIR$SELECTED_ENV/$config" "$HOME/$config"
done

# VIM setup
if ask_yes_no "Apply default VIM environment?"; then
    cp "$HOME/.vim/.vimrc-environment.default.vim" "$HOME/.vim/.vimrc-environment.vim"
    echo "--> default VIM environment installed."
fi

if ask_yes_no "Load VIM plugins now?"; then
    vim -c BundleInstall! -c q -c q -u "$HOME/.vim/.vimrc-bundles.vim"
    echo "--> VIM plugins are loaded."
fi

# Extra stuff
echo "Installing extra stuff:"

if ask_yes_no "Update colors in your system to match with VIM colorscheme?"; then
    bash "$SCRIPT_DIR/extra/gnome-terminal-colors-solarized/install.sh"
    echo "--> Colorscheme changed."
fi

if ask_yes_no "Install custom keyboard layout?"; then
    sudo cp "$SCRIPT_DIR/extra/keyboard_layouts/us" "/usr/share/X11/xkb/symbols/"
    echo "--> New layout copied to '/usr/share/X11/xkb/symbols/us'"
fi

if ask_yes_no "Install fonts in your system to match with VIM configuration?"; then
    cp -R "$SCRIPT_DIR/extra/powerline-fonts" "$HOME/.fonts"
    echo "Updating fonts..."
    fc-cache -fv | grep "fc-cache" || true
    echo "--> Fonts updated"
fi

if ask_yes_no "Set default rvm gems?"; then
    cp -R "$SCRIPT_DIR/extra/.rvm" "$HOME/"
    echo "--> Default RVM gems installed"
fi

if ask_yes_no "Add VIM app to GNOME like env menus?"; then
    cp -R "$SCRIPT_DIR/extra/.local" "$HOME/"
    echo "--> VIM app is added to menus"
fi

echo "Done."
echo "Have a nice day!"
