#!/usr/bin/env bash
# Media dropdown menu - play/pause, next, previous
chosen=$(echo -e "󰐊 Play/Pause\n󰒭 Next\n󰒮 Previous" | wofi -dmenu -i -p "Media" -W 220 -H 120)
case "$chosen" in
  *"Play/Pause"*) playerctl play-pause ;;
  *"Next"*)       playerctl next ;;
  *"Previous"*)   playerctl previous ;;
esac
