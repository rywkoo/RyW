#!/bin/bash

echo "🎮 Starting Proton & Wine setup..."

# Ensure an AUR helper is available
if command -v yay &>/dev/null; then
    AUR_HELPER="yay"
elif command -v paru &>/dev/null; then
    AUR_HELPER="paru"
else
    echo "❌ No AUR helper (yay or paru) found. Please install one before proceeding."
    exit 1
fi

# ─── Install Wine, Winetricks, Lutris, Proton-GE ──────────────
echo "🍷 Installing Wine, Winetricks, Lutris, and Proton-GE..."
$AUR_HELPER -S --needed --noconfirm \
    wine-staging \
    winetricks \
    lutris \
    protonup-qt \
    gamemode \
    lib32-gamemode

# ─── Setup Wine prefix ────────────────────────────────────────
echo "📁 Setting up initial Wine prefix..."
export WINEPREFIX="$HOME/.wine"
if [ ! -d "$WINEPREFIX" ]; then
    winecfg >/dev/null 2>&1
    echo "✅ Wine prefix created at $WINEPREFIX"
else
    echo "ℹ️ Wine prefix already exists at $WINEPREFIX, skipping winecfg."
fi


# ─── Suggest Steam Proton-GE Setup ────────────────────────────
echo "🧪 To install Proton-GE for Steam:"
echo "    1. Run 'protonup-qt' to download and manage custom Proton versions."
echo "    2. Launch it from your app launcher or run 'protonup-qt &' in terminal."
echo "    3. Select 'Steam' and install the latest Proton-GE build."

# ─── Final Touch ──────────────────────────────────────────────
echo "✅ Proton & Wine setup complete!"
