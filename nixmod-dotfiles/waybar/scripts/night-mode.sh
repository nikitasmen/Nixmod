#!/usr/bin/env bash
# Waybar night mode - toggle dark/light theme (GTK)
# Fallback: check gtk-theme-name or color-scheme
if [ "$1" = "toggle" ]; then
  if gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | grep -q dark; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null
  else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null
  fi
  exit 0
fi
scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null)
if echo "$scheme $theme" | grep -qiE 'dark|prefer-dark'; then
  echo '{"alt":"on","text":"󰖔","tooltip":"Dark mode"}'
else
  echo '{"alt":"off","text":"","tooltip":"Light mode (click to toggle)"}'
fi
