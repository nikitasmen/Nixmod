#!/usr/bin/env bash
# Waybar user + uptime module
user=$(whoami)

uptime_secs=$(awk '{print int($1)}' /proc/uptime)
days=$((uptime_secs / 86400))
hours=$(((uptime_secs % 86400) / 3600))
mins=$(((uptime_secs % 3600) / 60))
uptime_str=""
[ "$days" -gt 0 ] && uptime_str="${days}d "
uptime_str="${uptime_str}${hours}h ${mins}min"

printf '<span color="#8bd5ca">%s</span> (up %s <span color="#a6da95">↑</span>)' "$user" "$uptime_str"
