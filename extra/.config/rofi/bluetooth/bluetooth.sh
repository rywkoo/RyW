#!/bin/bash

rofi_theme="$HOME/.config/rofi/bluetooth/bluetooth.rasi"

# Turn Bluetooth on before doing anything
bluetoothctl power on

# Get list of unpaired devices
devices=$(bluetoothctl devices | while read -r line; do
    addr=$(echo "$line" | awk '{print $2}')
    paired=$(bluetoothctl info "$addr" | grep "Paired:" | awk '{print $2}')
    if [[ "$paired" == "no" ]]; then
        name=$(echo "$line" | cut -d' ' -f3-)
        echo "$addr $name"
    fi
done)

if [[ -z "$devices" ]]; then
    devices="No devices available at the moment"
fi

chosen=$(echo "$devices" | rofi -dmenu -p "Bluetooth: Pair device" -theme "$rofi_theme")
[[ -z "$chosen" || "$chosen" == "No devices available at the moment" ]] && exit 0

addr=$(echo "$chosen" | awk '{print $1}')

echo -e "pair $addr\nconnect $addr\nquit" | bluetoothctl
