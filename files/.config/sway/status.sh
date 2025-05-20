#!/bin/bash

# Threshold for low battery (percentage)
BATTERY_THRESHOLD=20

# Date and time (formatted as "May 9, 2025 10:00 PM")
date_formatted=$(date "+%b %d, %Y %I:%M %p")

# Battery level
battery_percentage=$(cat /sys/class/power_supply/BAT1/capacity)
battery_status=$(cat /sys/class/power_supply/BAT1/status)

# Colorize battery if below threshold
if [ "$battery_percentage" != "N/A" ]; then
    if [ "$battery_percentage" -le "$BATTERY_THRESHOLD" ] && [ "$battery_status" != "Charging" ]; then
        battery_output="BAT: <span color='#ff0000'>${battery_percentage}%</span>"
    else
        battery_output="BAT: <span color='#00ff00'>${battery_percentage}%</span>"
    fi
else
    battery_output="BAT: N/A"
fi

# Volume level (using PipeWire/PulseAudio)
volume=$(wpctl get-volume @DEFAULT_SINK@ | awk '{print $2 * 100}' | cut -d. -f1)
if wpctl get-volume @DEFAULT_SINK@ | grep -q MUTED; then
    volume_output="VOL: ${volume}% 🔇"
else
    volume_output="VOL: ${volume}%"
fi

# Output the status line with Pango markup for colors
echo "${battery_output} | ${volume_output} | ${date_formatted}"
