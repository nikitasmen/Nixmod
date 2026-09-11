#!/usr/bin/env bash
# Waybar geo module - check if geoclue/location active
if pgrep -x geoclue >/dev/null 2>&1 || pgrep -f geoclue >/dev/null 2>&1; then
  echo '{"alt":"on","text":"󰆇","tooltip":"Location services active"}'
else
  echo '{"alt":"off","text":"󰆇","tooltip":"Location (off)"}'
fi
