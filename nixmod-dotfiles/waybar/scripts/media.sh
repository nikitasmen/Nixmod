#!/usr/bin/env bash
# Waybar media module - playerctl status + tooltip with controls
status=$(playerctl status 2>/dev/null)
if [ -z "$status" ]; then
  echo '{"alt":"none","text":"","tooltip":"No player active\r\rLeft-click: Play/Pause\rRight-click: Next\rMiddle-click: Previous"}'
  exit 0
fi
artist=$(playerctl metadata artist 2>/dev/null | head -c 20)
title=$(playerctl metadata title 2>/dev/null | head -c 20)
text="${artist:-Unknown} - ${title:-Unknown}"
alt="Paused"
[ "$status" = "Playing" ] && alt="Playing"
# Tooltip: track info + controls (appears on hover under media section)
tooltip="${text}"$'\r\r'"󰐊 Left-click: Play/Pause"$'\r'"󰒭 Right-click: Next"$'\r'"󰒮 Middle-click: Previous"
# Escape for JSON
escape_json() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
text_esc=$(escape_json "$text")
tooltip_esc=$(escape_json "$tooltip")
printf '{"alt":"%s","text":"%s","tooltip":"%s"}\n' "$alt" "$text_esc" "$tooltip_esc"
