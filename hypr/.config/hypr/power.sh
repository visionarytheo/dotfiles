#!/bin/bash
option=$(printf "Logout\nReboot\nShutdown" | rofi -dmenu -p "Logout, Reboot or Shutdown?" -theme "/home/theo/.config/rofi/config-theme.rasi")

case "$option" in
    "Logout") 
        uwsm stop
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac
