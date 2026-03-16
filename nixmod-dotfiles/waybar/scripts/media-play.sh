#!/usr/bin/env bash
# Play/Pause icon for waybar - 󰐊 when playing, 󰏤 when paused
status=$(playerctl status 2>/dev/null)
[ "$status" = "Playing" ] && icon="󰐊" || icon="󰏤"
printf '{"text":"%s"}\n' "$icon"
