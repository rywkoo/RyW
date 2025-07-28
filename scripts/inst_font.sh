#!/bin/bash

echo "📦 Installing fonts..."

# Official repo fonts
sudo pacman -S --needed --noconfirm \
noto-fonts \
noto-fonts-emoji \
ttf-dejavu \
ttf-liberation \
ttf-opensans \
ttf-ubuntu-font-family \
otf-font-awesome

# Nerd Fonts (AUR)
FONTS_AUR=(
  nerd-fonts-jetbrains-mono
  nerd-fonts-fira-code
  nerd-fonts-hack
  nerd-fonts-iosevka
  nerd-fonts-meslo
)

# Detect yay or paru for AUR installs
AUR_HELPER=""
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
else
    echo "❌ No AUR helper found (yay or paru). Cannot install Nerd Fonts."
    exit 1
fi

echo "🎨 Installing Nerd Fonts..."
$AUR_HELPER -S --needed --noconfirm "${FONTS_AUR[@]}"

echo "🧹 Refreshing font cache..."
fc-cache -fv

echo "✅ Font installation complete!"
