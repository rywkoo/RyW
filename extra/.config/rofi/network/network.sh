#!/bin/bash

rofi_theme="$HOME/.config/rofi/network/network.rasi"

# Get current connected SSID
current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2)

# Get unique, non-empty SSIDs
wifi_list=$(nmcli -t -f SSID dev wifi list | grep -v '^$' | sort -u)

# Build list: connected SSID at top
entries=""
if [[ -n "$current_ssid" ]]; then
    entries="<b>$current_ssid [Connected]</b>\n"
fi

while read -r ssid; do
    [[ "$ssid" == "$current_ssid" ]] && continue
    entries+="$ssid\n"
done <<< "$wifi_list"

# Launch Wi-Fi selection
chosen=$(echo -e "$entries" | rofi -dmenu -markup-rows -i \
    -p "Select Wi-Fi" \
    -placeholder "Search for a connection" \
    -theme "$rofi_theme")

# Exit if canceled
[[ -z "$chosen" ]] && exit 0

# Clean raw SSID
ssid=$(echo "$chosen" | sed -E 's/<[^>]+>//g' | sed 's/ \[Connected\]//')

# Check if password is needed
security=$(nmcli -t -f SSID,SECURITY dev wifi list | grep "^$ssid:" | cut -d: -f2)

# Ask for password if needed
if [[ -n "$security" && "$security" != "--" ]]; then
    password=$(rofi -dmenu -password \
        -p "$ssid" \
        -placeholder "Enter password for $ssid" \
        -theme "$rofi_theme")
    [[ -z "$password" ]] && exit 1
    nmcli dev wifi connect "$ssid" password "$password"
else
    nmcli dev wifi connect "$ssid"
fi
