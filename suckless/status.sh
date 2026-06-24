#!/usr/bin/env bash

get_datetime() {
    date +" %a %d %b %Y |  %I:%M %p %Z "
}

get_mic_volume() {
    # Get the volume percentage from PulseAudio for the default source
    volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}' | sed 's/%//')
    # Get mute status
    mute=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
    if [ "$mute" = "yes" ]; then
        echo "󰍭"
    else
        echo "󰍬 $volume%"
    fi
}

get_volume() {
    # Get the volume percentage from PulseAudio
    volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
    # Get mute status
    mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    if [ "$mute" = "yes" ]; then
        echo "󰝟"
    else
        echo " $volume%"
    fi
}

get_internet_status() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "󰖩"
    else
        echo "󰖪"
    fi
}

get_status() {
    volume_status=$(get_volume)
    internet_status=$(get_internet_status)
     mic_status=$(get_mic_volume)
    
    echo " ${mic_status} | ${volume_status} | ${internet_status} | $(get_datetime)"
}

while true
do
    xsetroot -name "$(get_status)"
    sleep 0.1
done

