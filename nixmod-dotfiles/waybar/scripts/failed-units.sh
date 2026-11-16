#!/usr/bin/env bash
# Opened by clicking waybar's systemd-failed-units module: status + recent logs of every failed unit
{
  found=0
  for scope in --system --user; do
    for unit in $(systemctl "$scope" --failed --plain --no-legend | awk '{print $1}'); do
      found=1
      echo "━━━ $unit (${scope#--}) ━━━"
      # status header without the (often huge) CGroup process tree, then the unit's last log lines
      SYSTEMD_COLORS=1 systemctl "$scope" status --no-pager -n 0 "$unit" | sed '/CGroup:/,$d'
      SYSTEMD_COLORS=1 journalctl "$scope" -u "$unit" -b -n 30 --no-pager
      echo
    done
  done
  [ "$found" = 1 ] || echo "No failed units."
} | less -R
