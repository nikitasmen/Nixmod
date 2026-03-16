#!/usr/bin/env bash
# Media dropdown - appears below waybar like calendar, with play/pause, next, previous
# Position: top_right, 40px below bar (waybar height 36)
track=$(playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null | head -c 40)
[ -n "$track" ] && header="── $track ──" || header="── No player ──"

chosen=$(echo -e "$header\n󰐊 Play/Pause\n󰒭 Next\n󰒮 Previous" | wofi -dmenu -i -p "Media" \
  -l top_right -y 40 -W 280 -L 5 -j)
case "$chosen" in
  *"Play/Pause"*) playerctl play-pause ;;
  *"Next"*)       playerctl next ;;
  *"Previous"*)   playerctl previous ;;
esac
