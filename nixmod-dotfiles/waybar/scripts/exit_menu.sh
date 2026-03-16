
#!/bin/bash
chosen=$(echo -e "Lock\nLogout\nSuspend\nShutdown\nReboot" | wofi -dmenu -i -p "Exit Menu")
case "$chosen" in
  Lock) hyprlock ;;
  Logout) hyprctl dispatch exit ;;
  Suspend) systemctl suspend ;;
  Shutdown) systemctl poweroff ;;
  Reboot) systemctl reboot ;;
esac
