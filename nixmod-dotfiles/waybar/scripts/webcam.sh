#!/usr/bin/env bash
# Waybar webcam module - check if camera is in use
for dev in /dev/video*; do
  [ -e "$dev" ] || continue
  if lsof "$dev" 2>/dev/null | grep -q .; then
    echo '{"alt":"on","text":"󰖠"}'
    exit 0
  fi
done
echo '{"alt":"off","text":""}'
