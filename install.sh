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
OPENCODE_INSTALLED=false
KILOCLI_INSTALLED=false
PI_INSTALLED=false

# Check CLI commands in PATH
if command -v claude &> /dev/null; then
    echo "  -> Claude Code detected at $(which claude)"
    CLAUDE_INSTALLED=true
elif [ -f "$HOME/.local/bin/claude" ]; then
    echo "  -> Claude Code detected at ~/.local/bin/claude"
    CLAUDE_INSTALLED=true
fi

if command -v qwen &> /dev/null; then
    echo "  -> Qwen Code detected at $(which qwen)"
    QWEN_INSTALLED=true
elif [ -d "$HOME/.qwen" ]; then
    echo "  -> Qwen Code detected (~/.qwen exists)"
    QWEN_INSTALLED=true
fi

if command -v opencode &> /dev/null; then
    echo "  -> OpenCode detected at $(which opencode)"
    OPENCODE_INSTALLED=true
elif [ -d "$HOME/.config/opencode" ]; then
    echo "  -> OpenCode detected (~/.config/opencode exists)"
    OPENCODE_INSTALLED=true
fi

if command -v kilo &> /dev/null; then
    echo "  -> Kilo CLI detected at $(which kilo)"
    KILOCLI_INSTALLED=true
elif [ -d "$HOME/.config/kilo" ]; then
    echo "  -> Kilo CLI detected (~/.config/kilo exists)"
    KILOCLI_INSTALLED=true
fi

if command -v pi &> /dev/null; then
    echo "  -> Pi harness detected at $(which pi)"
    PI_INSTALLED=true
elif [ -d "$HOME/.pi" ]; then
    echo "  -> Pi harness detected (~/.pi exists)"
    PI_INSTALLED=true
fi

if [ "$CLAUDE_INSTALLED" = true ] || [ "$QWEN_INSTALLED" = true ] || [ "$OPENCODE_INSTALLED" = true ] || [ "$KILOCLI_INSTALLED" = true ] || [ "$PI_INSTALLED" = true ]; then
    echo ""
    echo "Installing AI configurations:"

    if ask_yes_no "Link shared skills to ~/.agents/skills/?"; then
        mkdir -p "$HOME/.agents"
        rm -rf "$HOME/.agents/skills" 2>/dev/null || true
        ln -s "$SCRIPT_DIR/ai/skills" "$HOME/.agents/skills"
        echo "  -> Linked skills to ~/.agents/skills/"
    fi

    # Claude Code setup
    if [ "$CLAUDE_INSTALLED" = true ]; then
        if ask_yes_no "Configure Claude Code?"; then
            mkdir -p "$HOME/.claude"
            rm -rf "$HOME/.claude/CLAUDE.md" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/AGENTS.md" "$HOME/.claude/CLAUDE.md"
            echo "  -> Linked AGENTS.md to ~/.claude/CLAUDE.md"

            rm -rf "$HOME/.claude/settings.json" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/settings/claude-settings.json" "$HOME/.claude/settings.json"
            echo "  -> Linked settings to ~/.claude/settings.json"
        fi
    fi

    # Qwen Code setup
    if [ "$QWEN_INSTALLED" = true ]; then
        if ask_yes_no "Configure Qwen Code?"; then
            mkdir -p "$HOME/.qwen"
            rm -rf "$HOME/.qwen/AGENTS.md" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/AGENTS.md" "$HOME/.qwen/AGENTS.md"
            echo "  -> Linked AGENTS.md to ~/.qwen/AGENTS.md"

            rm -rf "$HOME/.qwen/settings.json" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/settings/qwen-settings.json" "$HOME/.qwen/settings.json"
            echo "  -> Linked settings to ~/.qwen/settings.json"

            rm -rf "$HOME/.qwen/agents" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/agents" "$HOME/.qwen/agents"
            echo "  -> Linked agents to ~/.qwen/agents/"

            rm -rf "$HOME/.qwen/commands" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/commands" "$HOME/.qwen/commands"
            echo "  -> Linked commands to ~/.qwen/commands/"

            rm -rf "$HOME/.qwen/hooks" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/hooks" "$HOME/.qwen/hooks"
            echo "  -> Linked hooks to ~/.qwen/hooks/"

            # Link Qwen LSP configuration
            if [ -f "$SCRIPT_DIR/ai/qwen/.lsp.json" ]; then
                rm -rf "$HOME/.qwen/.lsp.json" 2>/dev/null || true
                ln -s "$SCRIPT_DIR/ai/qwen/.lsp.json" "$HOME/.qwen/.lsp.json"
                echo "  -> Linked .lsp.json to ~/.qwen/.lsp.json"
            fi
        fi
    fi

    # OpenCode setup
    if [ "$OPENCODE_INSTALLED" = true ]; then
        if ask_yes_no "Configure OpenCode?"; then
            rm -rf "$HOME/.config/opencode" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/opencode" "$HOME/.config/opencode"
            echo "  -> Linked opencode/ to ~/.config/opencode/"
        fi
    fi

    # Kilo CLI setup
    if [ "$KILOCLI_INSTALLED" = true ]; then
        if ask_yes_no "Configure Kilo CLI?"; then
            rm -rf "$HOME/.config/kilo/agents" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/opencode/agents" "$HOME/.config/kilo/agents"
            echo "  -> Linked agents to ~/.config/kilo/agents/"

            rm -rf "$HOME/.config/kilo/AGENTS.md" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/AGENTS.md" "$HOME/.config/kilo/AGENTS.md"
            echo "  -> Linked AGENTS.md to ~/.config/kilo/AGENTS.md"

            rm -rf "$HOME/.config/kilo/skills" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/skills" "$HOME/.config/kilo/skills"
            echo "  -> Linked skills to ~/.config/kilo/skills/"

            rm -rf "$HOME/.config/kilo/commands" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/commands" "$HOME/.config/kilo/commands"
            echo "  -> Linked commands to ~/.config/kilo/commands/"

            if [ -f "$SCRIPT_DIR/ai/opencode/opencode.json" ]; then
                rm -rf "$HOME/.config/kilo/opencode.json" 2>/dev/null || true
                ln -s "$SCRIPT_DIR/ai/opencode/opencode.json" "$HOME/.config/kilo/opencode.json"
                echo "  -> Linked opencode.json to ~/.config/kilo/opencode.json"
            fi
        fi
    fi

    # Pi harness setup
    if [ "$PI_INSTALLED" = true ]; then
        if ask_yes_no "Configure Pi harness?"; then
            rm -rf "$HOME/.pi" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/pi" "$HOME/.pi"
            echo "  -> Linked pi/ to ~/.pi/"
        fi
    fi

    echo "--> AI configurations installed."
    echo ""

    # Symlink update_ll.sh to llama.cpp if directory exists
    if [ -d "$HOME/code/llama.cpp" ]; then
        if ask_yes_no "Symlink update_ll.sh to ~/code/llama.cpp/update.sh?"; then
            rm -rf "$HOME/code/llama.cpp/update.sh" 2>/dev/null || true
            ln -s "$SCRIPT_DIR/ai/scripts/update_ll.sh" "$HOME/code/llama.cpp/update.sh"
            echo "  -> Linked update_ll.sh to ~/code/llama.cpp/update.sh"
        fi
    fi
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
