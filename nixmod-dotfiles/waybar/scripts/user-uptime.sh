#!/usr/bin/env bash
# Waybar user + uptime module (portable: uses /proc/uptime on Linux)
user=$(whoami)

if [ -r /proc/uptime ]; then
  # Linux: parse /proc/uptime (seconds)
  uptime_secs=$(awk '{print int($1)}' /proc/uptime)
  days=$((uptime_secs / 86400))
  hours=$(((uptime_secs % 86400) / 3600))
  mins=$(((uptime_secs % 3600) / 60))
  uptime_str=""
  [ "$days" -gt 0 ] && uptime_str="${days}d "
  uptime_str="${uptime_str}${hours}h ${mins}min"
else
  # Fallback: uptime -p (GNU/Linux) or plain uptime
  uptime_str=$(uptime -p 2>/dev/null | sed 's/up //' | tr -d ',')
  [ -z "$uptime_str" ] && uptime_str=$(uptime 2>/dev/null | sed 's/.*up *//' | sed 's/,.*//') || uptime_str="?"
fi

printf '<span color="#8bd5ca">%s</span> (up %s <span color="#a6da95">↑</span>)' "$user" "$uptime_str"
