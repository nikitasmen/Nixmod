#!/usr/bin/env bash
# Bottom-bar input (eww): query arrives on stdin.
# URL -> open, known command -> run (output via notification), else web search. "?" prefix forces search.
q=$(cat)
# eww kills onaccept commands after 200ms: detach everything after reading the input
[ -z "$CLI_DETACHED" ] && { CLI_DETACHED=1 setsid -f bash "$0" <<<"$q" >/dev/null 2>&1; exit 0; }

cd ~ || exit 1   # commands run from the home folder
q="${q#"${q%%[![:space:]]*}"}"   # trim leading space
eww update cli_q=x && eww update cli_q=   # clear the field (value must change to re-render)
bash ~/.config/eww/scripts/bar.sh unfocus   # drop keyboard focus back to the window
[ -n "$q" ] || exit 0

search() { xdg-open "https://duckduckgo.com/?q=$(jq -rn --arg q "$1" '$q|@uri')"; }

if [[ $q == \?* ]]; then
  search "${q#\?}"
elif [[ $q =~ ^(https?://|www\.)[^[:space:]]+$ || $q =~ ^[^[:space:]/]+\.[a-z]{2,}(/[^[:space:]]*)?$ ]]; then
  [[ $q == http* ]] || q="https://$q"
  xdg-open "$q"
elif command -v "${q%% *}" >/dev/null; then
  out=$(eval "$q" 2>&1 </dev/null)
  [ -n "$out" ] && notify-send -a cli "❯ $q" "$(tail -n 20 <<<"$out")"
else
  search "$q"
fi
