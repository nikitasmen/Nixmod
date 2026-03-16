#!/usr/bin/env bash
# Waybar media module - playerctl status
status=$(playerctl status 2>/dev/null)
if [ -z "$status" ]; then
  echo '{"alt":"none","text":""}'
  exit 0
fi
artist=$(playerctl metadata artist 2>/dev/null | head -c 15)
title=$(playerctl metadata title 2>/dev/null | head -c 15)
text="${artist:-Unknown} - ${title:-Unknown}"
alt="Paused"
[ "$status" = "Playing" ] && alt="Playing"
printf '{"alt":"%s","text":"%s"}\n' "$alt" "$text"
