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

# Fix for Hyprland 0.55.4 hyprctl crash:
# Using -j (JSON) avoids the formatting bug that causes a segfault.
# We also remove 'unload all' which is problematic in this version.
hyprctl -j hyprpaper preload "${FILES[$INDEX]}" 2>/dev/null
hyprctl -j hyprpaper wallpaper "$MONITOR,${FILES[$INDEX]}" 2>/dev/null
