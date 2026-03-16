#!/usr/bin/env bash
# Waybar media module - playerctl status + tooltip
status=$(playerctl status 2>/dev/null)
if [ -z "$status" ]; then
  echo '{"text":"","tooltip":"No player - Left: Play/Pause, Right: Next, Middle: Prev"}'
  exit 0
fi
artist=$(playerctl metadata artist 2>/dev/null | head -c 20)
title=$(playerctl metadata title 2>/dev/null | head -c 20)
text="${artist:-Unknown} - ${title:-Unknown}"
[ "$status" = "Playing" ] && icon="󰐊 " || icon="󰏤 "
text="${icon}${text}"
tooltip="${text} - Left: Play/Pause, Right: Next, Middle: Prev"
# Escape for JSON
text_esc=$(printf '%s' "$text" | sed 's/\\/\\\\/g; s/"/\\"/g')
tooltip_esc=$(printf '%s' "$tooltip" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"text":"%s","tooltip":"%s"}\n' "$text_esc" "$tooltip_esc"
