#!/usr/bin/env bash
DIR="$HOME/Pictures/lu"
STATE="/tmp/.current_wallpaper"

mapfile -t FILES < <(find "$DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort)
[[ ${#FILES[@]} -eq 0 ]] && exit 1

if [[ ! -f "$STATE" ]]; then
  INDEX=0
else
  INDEX=$(<"$STATE")
  INDEX=$(((INDEX + 1) % ${#FILES[@]}))
fi

echo "$INDEX" >"$STATE"

MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')

hyprctl hyprpaper unload all
hyprctl hyprpaper preload "${FILES[$INDEX]}"
hyprctl hyprpaper wallpaper "$MONITOR,${FILES[$INDEX]}"
