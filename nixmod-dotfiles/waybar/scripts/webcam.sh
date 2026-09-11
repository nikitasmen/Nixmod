#!/usr/bin/env bash
# Waybar webcam module - check if camera is in use
# Uses "class" for CSS: #custom-webcam.on (red when active) vs #custom-webcam.off (dimmed)
for dev in /dev/video*; do
  [ -e "$dev" ] || continue
  if lsof "$dev" 2>/dev/null | grep -q .; then
    echo '{"text":"󰖠","tooltip":"Webcam in use","class":"on"}'
    exit 0
  fi
done
echo '{"text":"󰖠","tooltip":"Webcam (off)","class":"off"}'
