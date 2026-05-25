#!/usr/bin/env bash

DIRECAO=$1

active=$(hyprctl activewindow -j)

# Se NÃO houver janela ativa ({}) ou se der string vazia:
if [ "$active" = "{}" ] || [ -z "$active" ]; then
    if [ "$DIRECAO" = "right" ]; then
        hyprctl dispatch workspace r+1
    elif [ "$DIRECAO" = "left" ]; then
        hyprctl dispatch workspace r-1
    fi
    exit 0
fi

# Se houver janela ativa, o script continua o comportamento normal:
active_x=$(echo "$active" | jq '.at[0]')
active_w=$(echo "$active" | jq '.size[0]')
active_right=$((active_x + active_w))
active_workspace=$(echo "$active" | jq '.workspace.id')

if [ "$DIRECAO" = "right" ]; then
    max_right=$(hyprctl clients -j | jq --arg ws "$active_workspace" '[.[] | select(.workspace.id == ($ws | tonumber) and .mapped == true) | .at[0] + .size[0]] | max')
    
    if [ $((active_right + 10)) -ge "$max_right" ]; then
        hyprctl dispatch workspace r+1
    else
        hyprctl dispatch movefocus r
    fi

elif [ "$DIRECAO" = "left" ]; then
    min_left=$(hyprctl clients -j | jq --arg ws "$active_workspace" '[.[] | select(.workspace.id == ($ws | tonumber) and .mapped == true) | .at[0]] | min')
    
    if [ $((active_x - 10)) -le "$min_left" ]; then
        hyprctl dispatch workspace r-1
    else
        hyprctl dispatch movefocus l
    fi
fi