#!/usr/bin/env bash
# Legacy hyprpaper wallpaper cycler, not bound to any key.
# SUPER + CTRL + Space runs ~/.config/hypr/scripts/change-wall-final.sh (awww).
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

# -j avoids a hyprctl segfault on Hyprland 0.55.4.
# Note: hyprpaper 0.8 dropped 'preload', so this no longer works.
hyprctl -j hyprpaper preload "${FILES[$INDEX]}" 2>/dev/null
hyprctl -j hyprpaper wallpaper "$MONITOR,${FILES[$INDEX]}" 2>/dev/null
