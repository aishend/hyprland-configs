#!/usr/bin/env bash

DIRECAO=$1
active=$(hyprctl activewindow -j)

if [ "$active" = "{}" ] || [ -z "$active" ]; then
    exit 1
fi

active_workspace=$(echo "$active" | jq '.workspace.id')
active_x=$(echo "$active" | jq '.at[0]')
active_w=$(echo "$active" | jq '.size[0]')
active_right=$((active_x + active_w))

# Se estiver no Scratchpad, o comando "move" apenas inverte janelas de posição
if [ "$active_workspace" -lt 0 ]; then
    if [ "$DIRECAO" = "right" ]; then
        hyprctl dispatch swapwindow r
    elif [ "$DIRECAO" = "left" ]; then
        hyprctl dispatch swapwindow l
    fi
    exit 0
fi

all_windows=$(hyprctl clients -j | jq --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber) and .mapped == true)')
max_right=0
min_left=99999

while read -r x w; do
    if [ -n "$x" ] && [ -n "$w" ]; then
        right=$((x + w))
        [ "$right" -gt "$max_right" ] && max_right=$right
        [ "$x" -lt "$min_left" ] && min_left=$x
    fi
done < <(echo "$all_windows" | jq -r '"\(.at[0]) \(.size[0])"')

if [ "$DIRECAO" = "right" ]; then
    if [ "$active_right" -ge "$max_right" ]; then
        hyprctl dispatch movetoworkspace r+1
    else
        hyprctl dispatch swapwindow r
    fi
elif [ "$DIRECAO" = "left" ]; then
    if [ "$active_x" -le "$min_left" ]; then
        hyprctl dispatch movetoworkspace r-1
    else
        hyprctl dispatch swapwindow l
    fi
fi