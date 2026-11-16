#!/usr/bin/env bash
# Print active window title ("title") or keyboard layout ("lang") now and on every Hyprland change.
fmt() {   # lang: "English (US)" -> "ENG (US)", like the old waybar module
  if [ "$1" = lang ]; then sed -u -E 's/^([[:alpha:]]{3})[[:alpha:]]*/\U\1/'; else cat; fi
}
case $1 in
  title) hyprctl -j activewindow | jq -r '.title // ""' ;;
  lang)  hyprctl -j devices | jq -r '.keyboards[] | select(.main) | .active_keymap' ;;
esac | fmt "$1"
[ "$1" = title ] && ev=activewindow || ev=activelayout
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
  while IFS= read -r line; do
    [[ $line == "$ev>>"* ]] && { v=${line#*>>}; echo "${v#*,}"; }   # strip "class," / "keyboard,"
  done | fmt "$1"
