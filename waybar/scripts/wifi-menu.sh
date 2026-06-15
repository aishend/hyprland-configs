#!/usr/bin/env bash
# =============================================================================
# wifi-menu.sh — Wi-Fi network manager
# =============================================================================
# Scans for available networks and lets the user connect, disconnect, or
# turn off Wi-Fi via Rofi. If the selected network requires a password,
# opens a Kitty terminal running nmcli --ask to prompt for it.
#
# Usage: wifi-menu.sh   (no arguments)
# Deps:  nmcli, rofi, kitty
# =============================================================================

THEME="$HOME/.config/rofi/themes/default.rasi"

wifi_enabled=$(nmcli radio wifi)

if [ "$wifi_enabled" = "disabled" ]; then
    nmcli radio wifi on
    exit
fi

# Build network list from cache (--rescan no avoids the 3-5 s hardware scan).
# NetworkManager rescans automatically in the background every ~30 s.
entries=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no 2>/dev/null | while IFS=: read -r in_use ssid signal security; do
    [ -z "$ssid" ] && continue
    if [ "$in_use" = "*" ]; then
        echo "● $ssid  (${signal}%) ${security}"
    else
        echo "○ $ssid  (${signal}%) ${security}"
    fi
done | sort -u)

menu=$(printf "%s\n─────────────────────\n Turn Off Wi-Fi\n Open Settings" "$entries")
selected=$(echo "$menu" | rofi -dmenu -p "Wi-Fi" -theme "$THEME" 2>/dev/null)

[ -z "$selected" ] && exit

case "$selected" in
    *"Turn Off Wi-Fi"*)
        nmcli radio wifi off ;;
    *"Open Settings"*)
        setsid nm-connection-editor & ;;
    "●"*)
        nmcli connection down "$(nmcli -t -f NAME,DEVICE connection show --active | head -1 | cut -d: -f1)" ;;
    "○"*)
        ssid=$(echo "$selected" | sed 's/^○ //' | sed 's/  (.*//')
        nmcli device wifi connect "$ssid" 2>/dev/null || \
            setsid kitty --title "Wi-Fi" nmcli --ask device wifi connect "$ssid" &
        ;;
esac
