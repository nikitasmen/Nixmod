#!/usr/bin/env bash
# Waybar user + uptime module
user=$(whoami)
uptime_str=$(uptime -p 2>/dev/null | sed 's/up //' | sed 's/ day/d/' | sed 's/ days/d/' | sed 's/ hour/h/' | sed 's/ hours/h/' | sed 's/ minute/min/' | sed 's/ minutes/min/' | tr -d ',')
printf '<span color="#8bd5ca">%s</span> (up %s <span color="#a6da95">↑</span>)' "$user" "$uptime_str"
