#!/bin/bash

# Accept optional base directory argument for locating plugin list
BASE_DIR="${1:-$(dirname "$0")}"

PLUGIN_LIST="$BASE_DIR/restore_zsh.lst"

echo "🐚 Starting shell setup..."

MY_SHELL="zsh"

if command -v zsh &>/dev/null; then
    echo "zsh detected"

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Updating Oh-My-Zsh..."
        zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/upgrade.sh)"
    fi

    OH_MY_ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$OH_MY_ZSH_CUSTOM"

    # Read plugin URLs from the plugin list file
    if [[ -f "$PLUGIN_LIST" ]]; then
        while IFS= read -r plugin_url; do
            # Skip empty lines or comments
            [[ -z "$plugin_url" || "$plugin_url" =~ ^# ]] && continue
            plugin_name=$(basename "$plugin_url" .git)
            if [[ ! -d "$OH_MY_ZSH_CUSTOM/$plugin_name" ]]; then
                echo "Cloning plugin $plugin_name..."
                git clone "$plugin_url" "$OH_MY_ZSH_CUSTOM/$plugin_name"
            else
                echo "Plugin $plugin_name already cloned."
            fi
        done < "$PLUGIN_LIST"
    else
        echo "⚠️ Plugin list file $PLUGIN_LIST not found. Skipping plugin cloning."
    fi

    CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
    ZSH_PATH=$(which zsh)
    if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
        echo "Changing default shell to $ZSH_PATH"
        chsh -s "$ZSH_PATH"
    else
        echo "Default shell is already zsh."
    fi

else
    echo "zsh not installed, skipping shell setup."
fi

echo "Shell setup done."
