#!/usr/bin/env bash
# Waybar net-graph module - sparkline of total traffic (down+up) on the default-route interface.
# Long-running (no "interval" in config): prints one JSON line per second, history kept in memory.
# Scaled to the busiest second in the window (min 10 KB/s so idle chatter stays flat);
# exact rates are in the tooltip.
WIDTH=12
BARS=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
hist=()

human() { # bytes/s -> short string
  awk -v b="$1" 'BEGIN { split("B KB MB GB", u); i = 1; while (b >= 1024 && i < 4) { b /= 1024; i++ }
    printf (i == 1 ? "%d%s/s" : "%.1f%s/s"), b, u[i] }'
}

read_bytes() { # prints "rx tx" for $1, or "0 0" if gone
  local d=/sys/class/net/$1/statistics
  if [ -r "$d/rx_bytes" ]; then echo "$(<"$d/rx_bytes") $(<"$d/tx_bytes")"; else echo "0 0"; fi
}

prev_if=""
while :; do
  iface=$(ip route show default 2>/dev/null | awk '{ for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit } }')
  if [ -z "$iface" ]; then
    echo '{"text":"","tooltip":"No default route","class":"idle"}'
    hist=(); prev_if=""; sleep 1; continue
  fi
  read -r rx tx < <(read_bytes "$iface")
  if [ "$iface" != "$prev_if" ]; then # first sample / interface changed: no delta yet
    prev_if=$iface; prx=$rx; ptx=$tx; sleep 1; continue
  fi
  drx=$((rx - prx)); dtx=$((tx - ptx)); prx=$rx; ptx=$tx
  ((drx < 0)) && drx=0; ((dtx < 0)) && dtx=0

  hist+=($((drx + dtx)))
  ((${#hist[@]} > WIDTH)) && hist=("${hist[@]:1}")
  max=10240; for v in "${hist[@]}"; do ((v > max)) && max=$v; done
  graph=""; for ((i = ${#hist[@]}; i < WIDTH; i++)); do graph+=${BARS[0]}; done # fixed width
  for v in "${hist[@]}"; do graph+=${BARS[$((v * 7 / max))]}; done

  class=active; ((drx + dtx < 1024)) && class=idle # under 1 KB/s: dim the graph
  printf '{"text":"%s","tooltip":"%s\\n󰁅 %s   󰁝 %s\\nscale %s","class":"%s"}\n' \
    "$graph" "$iface" "$(human "$drx")" "$(human "$dtx")" "$(human "$max")" "$class"
  sleep 1
done
