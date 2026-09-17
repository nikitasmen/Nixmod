#!/usr/bin/env bash
# Waybar kdeconnect module - shows reachable device count/status
mapfile -t available < <(kdeconnect-cli -a --id-name-only 2>/dev/null)

count=${#available[@]}

if [ "$count" -gt 0 ]; then
  names=$(printf '%s\n' "${available[@]}" | cut -d' ' -f2- | paste -sd, - | sed 's/,/, /g')
  jq -nc --arg text "󰦧 $count" --arg tooltip "Connected: $names" '{"alt":"connected","text":$text,"tooltip":$tooltip}'
else
  jq -nc '{"alt":"disconnected","text":"󰦧","tooltip":"No devices connected"}'
fi
