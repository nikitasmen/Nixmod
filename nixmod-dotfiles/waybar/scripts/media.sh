#!/usr/bin/env bash
# Waybar media module - icon in bar, dropdown tooltip with track + controls (like calendar)
status=$(playerctl status 2>/dev/null)
if [ -z "$status" ]; then
  echo '{"text":"","tooltip":"<tt>No player</tt>\n\n<span color=\"#a5adcb\">Left: Play/Pause  ·  Right: Next  ·  Middle: Prev</span>"}'
  exit 0
fi
artist=$(playerctl metadata artist 2>/dev/null | head -c 40 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
title=$(playerctl metadata title 2>/dev/null | head -c 40 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
[ "$status" = "Playing" ] && icon="󰐊" || icon="󰏤"
# Bar: icon only (compact controller)
text="$icon"
# Tooltip: dropdown-style with track info + control hints (Pango markup)
status_color="#8bd5ca"
[ "$status" = "Paused" ] && status_color="#a5adcb"
tooltip="<tt><b>${title:-Unknown}</b></tt>
<tt><span color='#a5adcb'>${artist:-Unknown}</span></tt>
<span color='$status_color'>$status</span>

<span color='#a6da95'>⏮ Prev</span>   <span color='#8bd5ca'>⏯ Play</span>   <span color='#a6da95'>⏭ Next</span>
<span color='#6e6c7e' size='small'>Left · Right · Middle click</span>"
# Escape for JSON
text_esc="${text//\\/\\\\}"; text_esc="${text_esc//\"/\\\"}"
tooltip_esc="${tooltip//\\/\\\\}"; tooltip_esc="${tooltip_esc//\"/\\\"}"; tooltip_esc="${tooltip_esc//$'\n'/\\n}"
printf '{"text":"%s","tooltip":"%s"}\n' "$text_esc" "$tooltip_esc"
