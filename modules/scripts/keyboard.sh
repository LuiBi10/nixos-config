#!/usr/bin/env bash

# Toggle US/Spanish layouts on all keyboards and notify

# All keyboard names
keyboards=$(hyprctl devices -j | jq -r '.keyboards[].name')

for kb in $keyboards; do
    hyprctl switchxkblayout "$kb" next
done

# Active layout of the main keyboard
NEW_LAYOUT=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

notify-send "Keyboard Layout" "Switched to: $NEW_LAYOUT" -i input-keyboard
