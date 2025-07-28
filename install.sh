#!/bin/bash

# Print big install banner immediately on start
echo "
     ___                       ___           ___           ___     
    /\  \                     /\  \         /|  |         /\  \    
   /::\  \         ___        \:\  \       |:|  |        /::\  \   
  /:/\:\__\       /|  |        \:\  \      |:|  |       /:/\:\  \  
 /:/ /:/  /      |:|  |    ___  \:\  \   __|:|  |      /:/  \:\  \ 
/:/_/:/__/___    |:|  |   /\  \  \:\__\ /\ |:|__|____ /:/__/ \:\__\
\:\/:::::/  /  __|:|__|   \:\  \ /:/  / \:\/:::::/__/ \:\  \ /:/  /
 \::/~~/~~~~  /::::\  \    \:\  /:/  /   \::/~~/~      \:\  /:/  / 
  \:\~~\      ~~~~\:\  \    \:\/:/  /     \:\~~\        \:\/:/  /  
   \:\__\          \:\__\    \::/  /       \:\__\        \::/  /   
    \/__/           \/__/     \/__/         \/__/         \/__/    

"

read -p "⚠️ This will install packages and modify your config. Proceed? (y/N): " confirm
if [[ "$confirm" != [yY] ]]; then
    echo "❌ Installation cancelled."
    exit 1
fi

# Define base paths relative to this script
SCRIPT_DIR="$(dirname "$0")/scripts"
EXTRA_DIR="$(dirname "$0")/extra"

# Fonts banner
echo "
     ___           ___           ___                  
    /\__\         /\  \         /\  \                 
   /:/ _/_       /::\  \        \:\  \         ___    
  /:/ /\__\     /:/\:\  \        \:\  \       /\__\   
 /:/ /:/  /    /:/  \:\  \   _____\:\  \     /:/  /   
/:/_/:/  /    /:/__/ \:\__\ /::::::::\__\   /:/__/    
\:\/:/  /     \:\  \ /:/  / \:\~~\~~\/__/  /::\  \    
 \::/__/       \:\  /:/  /   \:\  \       /:/\:\  \   
  \:\  \        \:\/:/  /     \:\  \      \/__\:\  \  
   \:\__\        \::/  /       \:\__\          \:\__\ 
    \/__/         \/__/         \/__/           \/__/ 

"
bash "$SCRIPT_DIR/inst_font.sh"

# App installation banner
echo "
     ___           ___         ___   
    /\  \         /\  \       /\  \  
   /::\  \       /::\  \     /::\  \ 
  /:/\:\  \     /:/\:\__\   /:/\:\__\
 /:/ /::\  \   /:/ /:/  /  /:/ /:/  /
/:/_/:/\:\__\ /:/_/:/  /  /:/_/:/  / 
\:\/:/  \/__/ \:\/:/  /   \:\/:/  /  
 \::/__/       \::/__/     \::/__/   
  \:\  \        \:\  \      \:\  \   
   \:\__\        \:\__\      \:\__\  
    \/__/         \/__/       \/__/  
"
if [[ -f "$SCRIPT_DIR/pac_1.txt" ]]; then
    echo "📦 Installing official packages from pac_1.txt..."
    sudo pacman -S --needed --noconfirm $(< "$SCRIPT_DIR/pac_1.txt")
else
    echo "⚠️ pac_1.txt not found. Skipping official packages."
fi

if [[ -f "$SCRIPT_DIR/pac_2.txt" ]]; then
    # Detect AUR helper first
    AUR_HELPER=""
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
    else
        echo "❌ No AUR helper found (yay or paru). Please install one first."
        exit 1
    fi

    echo "🚀 Installing AUR packages from pac_2.txt using $AUR_HELPER..."
    $AUR_HELPER -S --needed --noconfirm $(< "$SCRIPT_DIR/pac_2.txt")
else
    echo "⚠️ pac_2.txt not found. Skipping AUR packages."
fi

# Gaming banner
echo "
    /\__\         /\  \         /\  \         /\__\    
   /:/ _/_       /::\  \       |::\  \       /:/ _/_   
  /:/ /\  \     /:/\:\  \      |:|:\  \     /:/ /\__\  
 /:/ /::\  \   /:/ /::\  \   __|:|\:\  \   /:/ /:/ _/_ 
/:/__\/\:\__\ /:/_/:/\:\__\ /::::|_\:\__\ /:/_/:/ /\__\
\:\  \ /:/  / \:\/:/  \/__/ \:\~~\  \/__/ \:\/:/ /:/  /
 \:\  /:/  /   \::/__/       \:\  \        \::/_/:/  / 
  \:\/:/  /     \:\  \        \:\  \        \:\/:/  /  
   \::/  /       \:\__\        \:\__\        \::/  /   
    \/__/         \/__/         \/__/         \/__/ 
"
bash "$SCRIPT_DIR/inst_pw.sh"

# SDDM banner
echo "
     ___                                       ___     
    /\__\         _____         _____         /\  \    
   /:/ _/_       /::\  \       /::\  \       |::\  \   
  /:/ /\  \     /:/\:\  \     /:/\:\  \      |:|:\  \  
 /:/ /::\  \   /:/  \:\__\   /:/  \:\__\   __|:|\:\  \ 
/:/_/:/\:\__\ /:/__/ \:|__| /:/__/ \:|__| /::::|_\:\__\
\:\/:/ /:/  / \:\  \ /:/  / \:\  \ /:/  / \:\~~\  \/__/
 \::/ /:/  /   \:\  /:/  /   \:\  /:/  /   \:\  \      
  \/_/:/  /     \:\/:/  /     \:\/:/  /     \:\  \     
    /:/  /       \::/  /       \::/  /       \:\__\    
    \/__/         \/__/         \/__/         \/__/    
"
bash "$SCRIPT_DIR/inst_sddm.sh" "$EXTRA_DIR"

# Zsh banner
echo "
     ___           ___           ___     
    /\__\         /\__\         /\  \    
   /::|  |       /:/ _/_        \:\  \   
  /:/:|  |      /:/ /\  \        \:\  \  
 /:/|:|  |__   /:/ /::\  \   ___ /::\  \ 
/:/ |:| /\__\ /:/_/:/\:\__\ /\  /:/\:\__\
\/__|:|/:/  / \:\/:/ /:/  / \:\/:/  \/__/
    |:/:/  /   \::/ /:/  /   \::/__/     
    |::/  /     \/_/:/  /     \:\  \     
    |:/  /        /:/  /       \:\__\    
    |/__/         \/__/         \/__/    
"
bash "$SCRIPT_DIR/inst_shl.sh" "$SCRIPT_DIR"

# Dotfiles + wallpapers banner
echo "
     ___           ___         ___   
    /\  \         /\  \       /\  \  
   /::\  \       /::\  \     /::\  \ 
  /:/\:\  \     /:/\:\__\   /:/\:\__\
 /:/ /::\  \   /:/ /:/  /  /:/ /:/  /
/:/_/:/\:\__\ /:/_/:/  /  /:/_/:/  / 
\:\/:/  \/__/ \:\/:/  /   \:\/:/  /  
 \::/__/       \::/__/     \::/__/   
  \:\  \        \:\  \      \:\  \   
   \:\__\        \:\__\      \:\__\  
    \/__/         \/__/       \/__/  
"
bash "$SCRIPT_DIR/lst_setup.sh" "$EXTRA_DIR"

echo "✅ All done!"
