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

# AI Assistants Configuration
echo "Checking for AI assistants:"

CLAUDE_INSTALLED=false
QWEN_INSTALLED=false

if command -v claude &> /dev/null; then
    echo "  -> Claude Code detected at $(which claude)"
    CLAUDE_INSTALLED=true
fi

if command -v qwen &> /dev/null; then
    echo "  -> Qwen Code detected at $(which qwen)"
    QWEN_INSTALLED=true
fi

if [ "$CLAUDE_INSTALLED" = true ] || [ "$QWEN_INSTALLED" = true ]; then
    echo ""
    echo "Installing AI configurations:"

    # Claude Code setup
    if [ "$CLAUDE_INSTALLED" = true ]; then
        if ask_yes_no "Configure Claude Code?"; then
            mkdir -p "$HOME/.claude"
            rm -rf "$HOME/.claude/CLAUDE.md" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/AI.md" "$HOME/.claude/CLAUDE.md"
            echo "  -> Linked AI.md to ~/.claude/CLAUDE.md"

            rm -rf "$HOME/.claude/settings.json" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/settings/claude-settings.json" "$HOME/.claude/settings.json"
            echo "  -> Linked settings to ~/.claude/settings.json"

            rm -rf "$HOME/.claude/skills" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/skills" "$HOME/.claude/skills"
            echo "  -> Linked skills to ~/.claude/skills/"
        fi
    fi

    # Qwen Code setup
    if [ "$QWEN_INSTALLED" = true ]; then
        if ask_yes_no "Configure Qwen Code?"; then
            mkdir -p "$HOME/.qwen"
            rm -rf "$HOME/.qwen/QWEN.md" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/AI.md" "$HOME/.qwen/QWEN.md"
            echo "  -> Linked AI.md to ~/.qwen/QWEN.md"

            rm -rf "$HOME/.qwen/settings.json" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/settings/qwen-settings.json" "$HOME/.qwen/settings.json"
            echo "  -> Linked settings to ~/.qwen/settings.json"

            rm -rf "$HOME/.qwen/skills" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/skills" "$HOME/.qwen/skills"
            echo "  -> Linked skills to ~/.qwen/skills/"

            rm -rf "$HOME/.qwen/agents" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/agents" "$HOME/.qwen/agents"
            echo "  -> Linked agents to ~/.qwen/agents/"
        fi
    fi

    echo "--> AI configurations installed."
    echo ""
fi

# Select environment
PS3="Choose available environment: "
select SELECTED_ENV in $(ls -1A "$ENV_DIR"); do
    break
done

if ! ask_yes_no "Using $SELECTED_ENV as source. Is this correct?"; then
    exit
fi
echo "--> Perform $SELECTED_ENV environment install."

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

if ask_yes_no "Install git-delta (diff viewer)?"; then
    sudo apt install -y git-delta
    echo "--> git-delta installed"
fi

if ask_yes_no "Update colors in your system to match with VIM colorscheme?"; then
    bash "$SCRIPT_DIR/extra/gnome-terminal-colors-solarized/install.sh"
    echo "--> Colorscheme changed."
fi

if ask_yes_no "Install custom keyboard layout?"; then
    # Copy the custom XKB symbols file
    sudo cp "$SCRIPT_DIR/extra/keyboard_layouts/us" "/usr/share/X11/xkb/symbols/"

    # Create variant XML snippet for XKB rules
    cat > /tmp/dvorak_apk_variant.xml << 'XKBEOF'
        <variant>
          <configItem popularity="exotic">
            <name>dvorak-apk</name>
            <description>English (Dvorak, AP Keyboard)</description>
          </configItem>
        </variant>
XKBEOF

    # Find the line number for dvorak-classic in evdev.xml (dynamic search)
    EVDEV_LINE=$(grep -n 'name>dvorak-classic</name>' /usr/share/X11/xkb/rules/evdev.xml | head -1 | cut -d: -f1)
    if [ -n "$EVDEV_LINE" ]; then
        INSERT_LINE=$((EVDEV_LINE + 3))
        sudo sed -i "${INSERT_LINE}r /tmp/dvorak_apk_variant.xml" /usr/share/X11/xkb/rules/evdev.xml
    fi

    # Find the line number for dvorakprogr in base.extras.xml (dynamic search)
    EXTRAS_LINE=$(grep -n 'name>dvorakprogr</name>' /usr/share/X11/xkb/rules/base.extras.xml | head -1 | cut -d: -f1)
    if [ -n "$EXTRAS_LINE" ]; then
        INSERT_LINE=$((EXTRAS_LINE + 3))
        sudo sed -i "${INSERT_LINE}r /tmp/dvorak_apk_variant.xml" /usr/share/X11/xkb/rules/base.extras.xml
    fi

    # Recompile XKB database
    sudo dpkg-reconfigure xkb-data

    echo "--> Keyboard layout installed and registered in XKB rules"
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
