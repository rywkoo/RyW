#!/bin/bash

echo "🛠️ Starting dotfile and wallpaper restoration..."

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Project root is parent of scripts directory
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EXTRA_DIR="$PROJECT_ROOT/extra"

TARGET_CONFIG="$HOME/.config"
TARGET_WALLPAPER="$HOME/Pictures/wallpaper"

# ─── Copy .zshenv to home directory ─────────────────────────────
ZSHENV_SRC="$EXTRA_DIR/.zshenv"
ZSHENV_DST="$HOME/.zshenv"

if [[ -f "$ZSHENV_SRC" ]]; then
    echo "📄 Copying .zshenv to home directory..."
    cp "$ZSHENV_SRC" "$ZSHENV_DST"
    echo "✅ .zshenv copied."
else
    echo "⚠️ No .zshenv file found in $EXTRA_DIR, skipping."
fi

# ─── CONFIG COPY ───────────────────────────────────────────────
if [[ -d "$EXTRA_DIR/.config" ]]; then
    echo "📁 Copying config folders..."
    for dir in "$EXTRA_DIR/.config"/*; do
        if [[ -d "$dir" ]]; then
            base_dir=$(basename "$dir")
            echo "→ Replacing $TARGET_CONFIG/$base_dir"
            rm -rf "$TARGET_CONFIG/$base_dir"
            cp -r "$dir" "$TARGET_CONFIG/"
        fi
    done
else
    echo "⚠️ No .config folder found in $EXTRA_DIR"
fi

# ─── WALLPAPER COPY ─────────────────────────────────────────────
mkdir -p "$TARGET_WALLPAPER"

if [[ -d "$EXTRA_DIR/wallpaper" ]]; then
    echo "🖼️ Copying wallpapers (without deleting existing ones)..."
    find "$EXTRA_DIR/wallpaper" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | while read -r img; do
        base_img=$(basename "$img")
        target_path="$TARGET_WALLPAPER/$base_img"
        if [[ -f "$target_path" ]]; then
            echo "⚠️ Skipping existing: $base_img"
        else
            cp "$img" "$TARGET_WALLPAPER/"
            echo "✅ Copied: $base_img"
        fi
    done
else
    echo "⚠️ No wallpaper folder found in $EXTRA_DIR"
fi

echo "✅ Done restoring config and wallpapers."
