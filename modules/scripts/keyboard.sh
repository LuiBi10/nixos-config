#!/usr/bin/env bash

# This script toggles between US and Spanish keyboard layouts in Hyprland

# Get the list of all keyboard names
keyboards=$(hyprctl devices -j | jq -r '.keyboards[].name')

# Toggle layout for all keyboards
for kb in $keyboards; do
    hyprctl switchxkblayout "$kb" next
done

# Get the new layout name from the main keyboard
NEW_LAYOUT=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Notify the user
notify-send "Keyboard Layout" "Switched to: $NEW_LAYOUT" -i input-keyboard
