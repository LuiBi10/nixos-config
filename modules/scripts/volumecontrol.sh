#!/usr/bin/env bash
# Volume and mic control with dunst notifications (pamixer)

iDIR="$HOME/.config/dunst/icons/vol"

# Output volume
get_volume() {
    pamixer --get-volume
}

# Icon for the current volume
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
            # No icon for this exact level: generic one
            echo "$iDIR/vol-icon.svg"
        fi
    fi
}

# Volume notification
notify_user() {
    volume=$(get_volume)
    icon=$(get_icon)
    if [ "$(pamixer --get-mute)" == "true" ]; then
        dunstify -a "Volume" -r 91190 -u low -i "$icon" "Muted"
    else
        dunstify -a "Volume" -r 91190 -u low -h int:value:"$volume" -i "$icon" "Volume: $volume%"
    fi
}

# Unmute and raise volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u
    fi
    pamixer -i 5
    notify_user
}

# Unmute and lower volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u
    fi
    pamixer -d 5
    notify_user
}

# Toggle output mute
toggle_mute() {
    pamixer -t
    notify_user
}

# Toggle mic mute
toggle_mic() {
    pamixer --default-source -t
    notify_mic_user
}

# Mic icon
get_mic_icon() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        echo "$iDIR/muted-mic.svg"
    else
        echo "$iDIR/unmuted-mic.svg"
    fi
}

# Mic notification
notify_mic_user() {
    volume=$(pamixer --default-source --get-volume)
    icon=$(get_mic_icon)
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        dunstify -a "Microphone" -r 91191 -u low -i "$icon" "Mic Muted"
    else
        dunstify -a "Microphone" -r 91191 -u low -h int:value:"$volume" -i "$icon" "Mic: $volume%"
    fi
}

# Raise mic volume
inc_mic_volume() {
    pamixer --default-source -i 5
    notify_mic_user
}

# Lower mic volume
dec_mic_volume() {
    pamixer --default-source -d 5
    notify_mic_user
}

# Dispatch on the first argument
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
