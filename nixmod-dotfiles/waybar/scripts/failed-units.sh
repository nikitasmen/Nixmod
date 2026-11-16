#!/usr/bin/env bash
# Opened by clicking waybar's systemd-failed-units module: fzf picker of failed units
# with a details card + recent logs in the preview. Enter = restart, Ctrl-X = clear (reset-failed;
# journal logs are kept, it's "mark as read"). Tab marks several, Ctrl-A marks all.
export CLICOLOR_FORCE=1   # keep gum colors inside fzf's preview pipe
RED='#ed8796' GREEN='#a6da95' MAUVE='#c6a0f6' TEXT='#cad3f5' SUB='#a5adcb' OVL='#6e738d'

list() {
  for scope in system user; do
    systemctl --$scope --failed --plain --no-legend | while read -r unit _; do
      printf '%s\t%s\t%s\n' "$scope" "$unit" "$(systemctl --$scope show -P Result "$unit")"
    done
  done | awk -F'\t' -v r="\033[38;2;237;135;150m" -v d="\033[38;2;110;115;141m" -v n="\033[0m" \
    '{ printf "%s\t%s\t%s✗%s %s  %s%s · %s%s\n", $1, $2, r, n, $2, d, $1, $3, n }'
}

preview() {  # $1=scope $2=unit
  local s=$1 u=$2 desc res code since
  desc=$(systemctl --$s show -P Description "$u")
  res=$(systemctl --$s show -P Result "$u")
  code=$(systemctl --$s show -P ExecMainStatus "$u")
  since=$(systemctl --$s show -P StateChangeTimestamp "$u")
  gum style --border rounded --border-foreground "$RED" --padding "0 2" --width "$((FZF_PREVIEW_COLUMNS - 2))" \
    "$(gum style --bold --foreground "$RED" "✗ $u")" \
    "$(gum style --foreground "$TEXT" "$desc")" "" \
    "$(gum style --foreground "$SUB" "scope   $s")" \
    "$(gum style --foreground "$SUB" "result  $res (exit $code)")" \
    "$(gum style --foreground "$SUB" "since   $since")"
  gum style --foreground "$MAUVE" --bold --margin "1 0 0 1" "Recent logs · newest first"
  SYSTEMD_COLORS=1 journalctl --$s -u "$u" -b -n 40 --no-pager --no-hostname -o short 2>&1 | tac
}

case $1 in
  list) list; exit ;;
  preview) preview "$2" "$3"; exit ;;
esac

if [ -z "$(list)" ]; then
  clear
  gum style --border rounded --border-foreground "$GREEN" --padding "1 4" --margin "2 4" \
    "$(gum style --bold --foreground "$GREEN" "✓ All good")" "$(gum style --foreground "$SUB" "No failed units.")"
  read -rsn1; exit
fi

self=$(readlink -f "$0")
list | fzf --ansi --delimiter='\t' --with-nth=3 --no-sort --layout=reverse --multi \
  --border=rounded --border-label=' 󰀦 Failed units ' --prompt='  ' --pointer='▌' \
  --header='enter restart · tab mark · ctrl-a all · ctrl-x clear marked · esc close' --header-first \
  --preview="$self preview {1} {2}" --preview-window='right,68%,wrap,border-left' \
  --bind="enter:execute(systemctl --{1} restart {2})+reload($self list)" \
  --bind="ctrl-a:select-all" \
  --bind="ctrl-x:execute(while IFS=\$'\\t' read -r s u _; do systemctl --\$s reset-failed \"\$u\"; done < {+f})+clear-selection+reload($self list)" \
  --color="bg:#24273a,bg+:#363a4f,fg:$TEXT,fg+:$TEXT,hl:$RED,hl+:$RED,header:$OVL,info:$MAUVE" \
  --color="pointer:$RED,prompt:$MAUVE,border:$OVL,label:$RED,spinner:#f4dbd6,marker:#b7bdf8"
