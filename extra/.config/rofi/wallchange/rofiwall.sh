#!/usr/bin/env bash

# ─── Setup ──────────────────────────────────────────────────────────────────────
WALL_DIR="$HOME/Pictures/wallpaper"
HYPR_CONF="$HOME/.config/hypr/appearance.conf"
ROFI_IMAGE_DIR="$HOME/.config/rofi/image"
ROFI_BG="$ROFI_IMAGE_DIR/background.jpg"
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
HYPRLOCK_IMAGE="$HOME/.config/hypr/hyprlock/image/image.jpg"
CAVA_CONFIG="$HOME/.config/cava/config"
WAL_COLORS="$HOME/.cache/wal/colors.json"
SDDM_BG_DIR="/usr/share/sddm/themes/RyW/Backgrounds"
SDDM_BG_PATH="$SDDM_BG_DIR/background.jpg"

# ─── Wallpaper Selection via Rofi ───────────────────────────────────────────────
WALLPAPER_NAME=$(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) \
  | sort \
  | xargs -n1 basename \
  | rofi -dmenu -theme "$HOME/.config/rofi/wallchange/network.rasi" -p "🎨 Select wallpaper")

[[ -z "$WALLPAPER_NAME" ]] && exit 0

WALLPAPER="$WALL_DIR/$WALLPAPER_NAME"

# ─── Set Wallpaper ──────────────────────────────────────────────────────────────
swww img "$WALLPAPER" --transition-type grow --transition-pos 0.5,0.99

# Ensure the directory exists (with sudo since /usr/share is root-owned)
sudo mkdir -p "$SDDM_BG_DIR"

# Copy wallpaper with elevated permissions
if [ -f "$WALLPAPER" ]; then
    sudo cp "$WALLPAPER" "$SDDM_BG_PATH"
    echo "✔ Copied wallpaper to $SDDM_BG_PATH"
fi

# ─── Prepare Rofi Background Image ──────────────────────────────────────────────
mkdir -p "$ROFI_IMAGE_DIR"
convert "$WALLPAPER" -resize 1920x1080^ -gravity center -crop 1920x700+0-100 +repage "$ROFI_BG"

# ─── Generate pywal Colors ──────────────────────────────────────────────────────
wal -i "$WALLPAPER" --saturate 0.8 -n

# ─── Reload GUI Components ──────────────────────────────────────────────────────
pkill swaync 
sleep 1

# ─── Parse pywal Colors ─────────────────────────────────────────────────────────
GRADIENT_COLORS=($(jq -r '.colors | [.color0, .color1, .color2, .color3, .color4, .color5, .color6, .color7] | .[]' "$WAL_COLORS"))
FOREGROUND=$(jq -r '.special.foreground' "$WAL_COLORS")
BACKGROUND=$(jq -r '.special.background' "$WAL_COLORS")

# ─── Update Cava Config ─────────────────────────────────────────────────────────
cat > "$CAVA_CONFIG" <<EOF
[general]
framerate = 60
autosens = 1
sensitivity = 100
bars = 0
bar_width = 2
bar_spacing = 1
lower_cutoff_freq = 50
higher_cutoff_freq = 10000
sleep_timer = 0

[input]
method = pulse
source = auto

[output]
method = noncurses
channels = stereo
orientation = bottom
synchronized_sync = 1
xaxis = none
show_idle_bar_heads = 1

[color]
background = "$BACKGROUND"
foreground = "$FOREGROUND"
gradient = 1
gradient_color_1 = "${GRADIENT_COLORS[0]}"
gradient_color_2 = "${GRADIENT_COLORS[1]}"
gradient_color_3 = "${GRADIENT_COLORS[2]}"
gradient_color_4 = "${GRADIENT_COLORS[3]}"
gradient_color_5 = "${GRADIENT_COLORS[4]}"
gradient_color_6 = "${GRADIENT_COLORS[5]}"
gradient_color_7 = "${GRADIENT_COLORS[6]}"
gradient_color_8 = "${GRADIENT_COLORS[7]}"

[smoothing]
noise_reduction = 77

[eq]
1 = 1
2 = 1
3 = 1
4 = 1
5 = 1
EOF

# ─── Update Hyprland Borders ────────────────────────────────────────────────────
c1="${GRADIENT_COLORS[1]:1}ee"
c3="${GRADIENT_COLORS[3]:1}ee"
c4="${GRADIENT_COLORS[4]:1}aa"
c2="${GRADIENT_COLORS[2]:1}aa"

sed -i "s/^col\.active_border = .*/col.active_border = rgba($c1) rgba($c3) 45deg/" "$HYPR_CONF"
sed -i "s/^col\.inactive_border = .*/col.inactive_border = rgba($c4) rgba($c2) 45deg/" "$HYPR_CONF"

# ─── Update SDDM Theme Colors ───────────────────────────────────────────────────
# Make a copy we can safely modify without sudo
# Update red_brim.conf with colors from pywal (same as before)

echo "Before sed (first 10 lines):"
sudo head -n 10 /usr/share/sddm/themes/RyW/theme.conf

sudo sed -i -E \
  -e "s|^(HeaderTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(DateTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(TimeTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(FormBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[1]}\"|" \
  -e "s|^(BackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[1]}\"|" \
  -e "s|^(DimBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[1]}\"|" \
  -e "s|^(LoginFieldBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[2]}\"|" \
  -e "s|^(PasswordFieldBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[2]}\"|" \
  -e "s|^(LoginFieldTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(PasswordFieldTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(UserIconColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(PasswordIconColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(PlaceholderTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(WarningColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(LoginButtonTextColor *= *).*$|\1\"${GRADIENT_COLORS[7]}\"|" \
  -e "s|^(LoginButtonBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[5]}\"|" \
  -e "s|^(SystemButtonsIconsColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(SessionButtonTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(VirtualKeyboardButtonTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(DropdownTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(DropdownSelectedBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[2]}\"|" \
  -e "s|^(DropdownBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[1]}\"|" \
  -e "s|^(HighlightTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(HighlightBackgroundColor *= *).*$|\1\"${GRADIENT_COLORS[2]}\"|" \
  -e "s|^(HighlightBorderColor *= *).*$|\1\"transparent\"|" \
  -e "s|^(HoverUserIconColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(HoverPasswordIconColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(HoverSystemButtonsIconsColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(HoverSessionButtonTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  -e "s|^(HoverVirtualKeyboardButtonTextColor *= *).*$|\1\"${GRADIENT_COLORS[4]}\"|" \
  /usr/share/sddm/themes/RyW/theme.conf


echo "After sed (first 10 lines):"
sudo head -n 10 /usr/share/sddm/themes/RyW/theme.conf


notify-send "🎨 SDDM Theme Updated" "Colors synced with wallpaper and SDDM restarted."

# ─── Update Hyprlock Wallpaper and Colors ─────────────────────────
mkdir -p "$(dirname "$HYPRLOCK_IMAGE")"
convert "$WALLPAPER" -resize 1920x1080\! -gravity center -crop 1920x1080+0+0 +repage "$HYPRLOCK_IMAGE"

hex_to_rgba() {
    local hex=${1#"#"}
    local alpha=${2:-1}
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "rgba($r, $g, $b, $alpha)"
}

outer_rgba=$(hex_to_rgba "$BACKGROUND" 0.0)
inner_rgba=$(hex_to_rgba "$BACKGROUND" 0.36)
font_rgba=$(hex_to_rgba "$FOREGROUND" 0.9)
check_rgba=$(hex_to_rgba "${GRADIENT_COLORS[2]}" 1.0)
placeholder_hex="${FOREGROUND}"

# Save ownership and permissions before editing
owner_group=$(stat -c '%u:%g' "$HYPRLOCK_CONF")
mode=$(stat -c '%a' "$HYPRLOCK_CONF")

# Update only the background path line in the background block
awk -v newpath="$HYPRLOCK_IMAGE" '
  BEGIN { in_block=0 }
  /^background *{/ { in_block=1 }
  /^}/ { if(in_block) in_block=0 }
  {
    if(in_block && $1=="path" && $2=="=") {
      print "    path = " newpath
    } else {
      print $0
    }
  }
' "$HYPRLOCK_CONF" > "${HYPRLOCK_CONF}.tmp"

# Overwrite original file content without changing inode
cat "${HYPRLOCK_CONF}.tmp" > "$HYPRLOCK_CONF"
rm "${HYPRLOCK_CONF}.tmp"

# Update input-field colors in-place
sed -i "s/^\s*outer_color = .*/    outer_color = $outer_rgba/" "$HYPRLOCK_CONF"
sed -i "s/^\s*inner_color = .*/    inner_color = $inner_rgba/" "$HYPRLOCK_CONF"
sed -i "s/^\s*font_color = .*/    font_color = $font_rgba/" "$HYPRLOCK_CONF"
sed -i "s/^\s*check_color = .*/    check_color = $check_rgba/" "$HYPRLOCK_CONF"
sed -i -E "s|^\s*placeholder_text\s*=.*|    placeholder_text = <b><span foreground=\"#$placeholder_hex\">password...</span></b>|" "$HYPRLOCK_CONF"

# Restore original ownership and permissions
sudo chown "$owner_group" "$HYPRLOCK_CONF"
sudo chmod "$mode" "$HYPRLOCK_CONF"

# ─── Reload Cava & Hyprland ───────────────────────────────
pkill -SIGUSR1 cava
hyprctl reload
sleep 3
swaync &

# ─── Notify ──────────────────────────────────────
notify-send "✅ Wallpaper Applied" "$(basename "$WALLPAPER") - All components synced (Hyprland, Hyprlock, SDDM, Cava)."
