#!/usr/bin/env bash

iDIR="$HOME/.config/dunst/icons/vol"

# Get Volume
get_volume() {
    pamixer --get-volume
}

# Get Icon
get_icon() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        echo "$iDIR/muted-speaker.svg"
    else
        current=$(get_volume)
        if [ "$current" -eq 0 ]; then
            echo "$iDIR/vol-0.svg"
        elif [ -f "$iDIR/vol-$current.svg" ]; then
            echo "$iDIR/vol-$current.svg"
        else
            # Fallback to nearest tens or general icon
            echo "$iDIR/vol-icon.svg"
        fi
    fi
}

# Notify
notify_user() {
    volume=$(get_volume)
    icon=$(get_icon)
    if [ "$(pamixer --get-mute)" == "true" ]; then
        dunstify -a "Volume" -r 91190 -u low -i "$icon" "Muted"
    else
        dunstify -a "Volume" -r 91190 -u low -h int:value:"$volume" -i "$icon" "Volume: $volume%"
    fi
}

# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u
    fi
    pamixer -i 5
    notify_user
}

# Decrease Volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u
    fi
    pamixer -d 5
    notify_user
}

# Toggle Mute
toggle_mute() {
    pamixer -t
    notify_user
}

# Toggle Mic
toggle_mic() {
    pamixer --default-source -t
    notify_mic_user
}

# Get Mic Icon
get_mic_icon() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        echo "$iDIR/muted-mic.svg"
    else
        echo "$iDIR/unmuted-mic.svg"
    fi
}

# Notify for Microphone
notify_mic_user() {
    volume=$(pamixer --default-source --get-volume)
    icon=$(get_mic_icon)
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        dunstify -a "Microphone" -r 91191 -u low -i "$icon" "Mic Muted"
    else
        dunstify -a "Microphone" -r 91191 -u low -h int:value:"$volume" -i "$icon" "Mic: $volume%"
    fi
}

# Increase MIC Volume
inc_mic_volume() {
    pamixer --default-source -i 5
    notify_mic_user
}

# Decrease MIC Volume
dec_mic_volume() {
    pamixer --default-source -d 5
    notify_mic_user
}

# Execute accordingly
case "$1" in
    "--get") get_volume ;;
    "--inc") inc_volume ;;
    "--dec") dec_volume ;;
    "--toggle") toggle_mute ;;
    "--toggle-mic") toggle_mic ;;
    "--mic-inc") inc_mic_volume ;;
    "--mic-dec") dec_mic_volume ;;
    *) get_volume ;;
esac
