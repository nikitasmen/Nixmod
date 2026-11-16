#!/usr/bin/env bash
# (no args) open the bottom bar on every monitor.
# focus      open the prompt (a copy of the bar with the input expanded, exclusive keyboard)
#            exactly over the bar on the focused monitor; enter the "cli" submap (Escape).
# unfocus    close the prompt and leave the submap.
pos() { hyprctl -j layers | jq -r --arg m "$1" --arg ns "$2" '.[$m].levels[][] | select(.namespace == $ns) | "\(.x) \(.y)"'; }

case $1 in
  focus)
    m=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')
    cache="${XDG_RUNTIME_DIR:-/tmp}/eww-prompt-offset-$m"
    if [ ! -s "$cache" ]; then
      # The prompt is a non-exclusive overlay, so Hyprland places it inside the space other
      # bars reserve. Measure that once per session and cancel it with negative margins.
      eww open prompt --id prompt --arg monitor="$m" --arg dx=0 --arg dy=0
      sleep 0.1
      read -r bx by < <(pos "$m" eww-bottombar)
      read -r px py < <(pos "$m" eww-prompt)
      echo "$((bx - px)) $((py - by))" >"$cache"
      eww close prompt
    fi
    read -r dx dy <"$cache"
    eww open prompt --id prompt --arg monitor="$m" --arg dx="$dx" --arg dy="$dy"
    hyprctl dispatch 'hl.dsp.submap("cli")' >/dev/null ;;
  unfocus)
    hyprctl dispatch 'hl.dsp.submap("reset")' >/dev/null
    eww close prompt 2>/dev/null ;;
  *)
    for m in $(hyprctl -j monitors | jq -r '.[].name'); do
      eww open bottombar --id "bar-$m" --arg monitor="$m"
    done ;;
esac
