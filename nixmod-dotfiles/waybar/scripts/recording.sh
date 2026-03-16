#!/usr/bin/env bash
# Waybar recording module - check if screen recording
if pgrep -x wl-screenrec >/dev/null 2>&1; then
  echo '{"alt":"on","text":"󰑓"}'
else
  echo '{"alt":"off","text":""}'
fi
