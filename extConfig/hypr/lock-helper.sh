
#!/usr/bin/env bash

# Launch cava in background
cava -p ~/.config/cava/config 

# Launch pipes-rs in background
pipes-rs 

# Loop: draw now playing info and buttons on screen
while true; do
  song_info=$(playerctl metadata --format '{{title}} - {{artist}}')
  playing=$(playerctl status)

  # Clear screen (if needed) or just overwrite with echo
  clear
  echo -e "\n\n Now Playing: $song_info"
  echo -e "Status: $playing"
  echo -e "[P] Play/Pause    [N] Next    [B] Previous"

  # Read key input and control playback
  read -rsn1 input
  case "$input" in
    p|P) playerctl play-pause ;;
    n|N) playerctl next ;;
    b|B) playerctl previous ;;
  esac

  sleep 1
done
