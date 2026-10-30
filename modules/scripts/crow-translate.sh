#!/usr/bin/env bash

# Translate the selected text (primary selection) with Crow and notify.
# Crow's own "translate selection" can't read the selection on Hyprland
# (Qt only sees it with focus), so read it via wl-paste and translate it
# through Mozhi (the backend Crow uses), with Crow's CLI as a fallback.

LOG="${XDG_RUNTIME_DIR:-/tmp}/crow-translate.log"
# Zathura is set to copy selections to the clipboard (selection-clipboard)
CLASS=$(hyprctl activewindow -j | jq -r '.class')
if [ "$CLASS" = "org.pwmt.zathura" ]; then
    # PDFs break lines mid-sentence, so join them
    TEXT=$(wl-paste --no-newline 2>>"$LOG" | tr '\n' ' ')
else
    TEXT=$(wl-paste --primary --no-newline 2>>"$LOG")
fi
echo "$(date '+%F %T') [$CLASS] selection: ${TEXT:0:200}" >> "$LOG"

if [ -z "$TEXT" ]; then
    notify-send "Crow Translate" "No hay texto seleccionado" -i crow-translate
    exit 0
fi

# Query Mozhi directly with curl: starting Crow's CLI adds ~1.5s per run.
# DuckDuckGo engine is the fastest one; the second instance is a fallback.
INSTANCES=("https://mozhi.ducks.party" "https://mozhi.pussthecat.org")

# Prints "<detected language>\t<translation>"
translate() {
    local inst
    for inst in "${INSTANCES[@]}"; do
        curl -m 5 -sf -G "$inst/api/translate" \
            --data-urlencode engine=duckduckgo \
            --data-urlencode from=auto \
            --data-urlencode "to=$1" \
            --data-urlencode "text=$TEXT" 2>>"$LOG" |
            jq -er '[.detected, ."translated-text"] | @tsv' 2>>"$LOG" && return 0
    done
    return 1
}

# Translate to Spanish; if it is already Spanish, translate to English
if OUT=$(translate es); then
    DETECTED=${OUT%%$'\t'*}
    RESULT=${OUT#*$'\t'}
    if [ "$DETECTED" = "es" ]; then
        OUT=$(translate en) && RESULT=${OUT#*$'\t'}
    fi
    # @tsv escapes newlines/tabs, so turn them back
    RESULT=$(printf '%b' "$RESULT")
else
    # Both instances failed: fall back to Crow's CLI (slower)
    RESULT=$(crow -b -t es "$TEXT" 2>/dev/null)
fi

if [ -z "$RESULT" ]; then
    notify-send "Crow Translate" "Error al traducir" -i crow-translate -u critical
    exit 1
fi

# Middle click on the notification (dunst do_action) copies the translation
ACTION=$(notify-send "Crow Translate" "$RESULT" -i crow-translate -t 5000 -A "default=Copiar")
if [ "$ACTION" = "default" ]; then
    echo -n "$RESULT" | wl-copy
fi
