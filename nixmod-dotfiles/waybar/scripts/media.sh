#!/usr/bin/env bash
# Waybar media module - playerctl status + tooltip with controls
status=$(playerctl status 2>/dev/null)
if [ -z "$status" ]; then
  echo '{"alt":"none","text":"","tooltip":"No player - Left: Play/Pause, Right: Next, Middle: Prev"}'
  exit 0
fi
artist=$(playerctl metadata artist 2>/dev/null | head -c 20)
title=$(playerctl metadata title 2>/dev/null | head -c 20)
text="${artist:-Unknown} - ${title:-Unknown}"
alt="Paused"
[ "$status" = "Playing" ] && alt="Playing"
tooltip="${text} - Left: Play/Pause, Right: Next, Middle: Prev"
# Escape " and \ for JSON
text_esc=$(printf '%s' "$text" | sed 's/\\/\\\\/g; s/"/\\"/g')
tooltip_esc=$(printf '%s' "$tooltip" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"alt":"%s","text":"%s","tooltip":"%s"}\n' "$alt" "$text_esc" "$tooltip_esc"
