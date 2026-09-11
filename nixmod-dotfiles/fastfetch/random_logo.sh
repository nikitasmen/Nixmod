#!/usr/bin/env bash

# Fastfetch Random Display Logo Wrapper
# Retrieves a random .txt file from the installed config logos directory
LOGO_DIR="$HOME/.config/fastfetch/logos"

if [ -d "$LOGO_DIR" ]; then
    RANDOM_LOGO=$(find "$LOGO_DIR" -type f -name "*.txt" | shuf -n 1)
    if [ -n "$RANDOM_LOGO" ]; then
        fastfetch --logo "$RANDOM_LOGO" --logo-type file
        exit 0
    fi
fi

fastfetch
