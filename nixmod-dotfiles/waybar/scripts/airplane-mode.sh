#!/usr/bin/env bash
# Waybar airplane mode - rfkill status
if [ "$1" = "toggle" ]; then
  if rfkill list wifi | grep -q "Soft blocked: yes"; then
    rfkill unblock wifi 2>/dev/null
    rfkill unblock bluetooth 2>/dev/null
  else
    rfkill block wifi 2>/dev/null
    rfkill block bluetooth 2>/dev/null
  fi
  exit 0
fi
if rfkill list wifi 2>/dev/null | grep -q "Soft blocked: yes"; then
  echo '{"alt":"on","text":"󰀝"}'
else
  echo '{"alt":"off","text":""}'
fi
