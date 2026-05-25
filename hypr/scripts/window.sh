#!/usr/bin/env bash

# 1. Obter info da janela ativa
active=$(hyprctl activewindow -j)
if [ "$active" = "{}" ] || [ -z "$active" ]; then
    echo "Nenhuma janela focada para mover."
    exit 1
fi

# Extrair coordenadas da janela ativa
active_x=$(echo "$active" | jq '.at[0]')
active_w=$(echo "$active" | jq '.size[0]')
active_right=$((active_x + active_w))
active_workspace=$(echo "$active" | jq '.workspace.id')

# 2. Obter todas as janelas do MESMO workspace
all_windows=$(hyprctl clients -j | jq --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber) and .mapped == true)')

# 3. Inicializar variáveis para encontrar os limites
max_right=0
min_left=99999

# 4. Processar a geometria de cada janela
while read -r x w; do
    if [ -n "$x" ] && [ -n "$w" ]; then
        right=$((x + w))
        [ "$right" -gt "$max_right" ] && max_right=$right
        [ "$x" -lt "$min_left" ] && min_left=$x
    fi
done < <(echo "$all_windows" | jq -r '"\(.at[0]) \(.size[0])"')

# 5. Aceitar argumento para saber se queremos mover para a Direita ou Esquerda
# Exemplo: ./mover_janela_pop.sh right ou ./mover_janela_pop.sh left
DIRECAO=$1

if [ "$DIRECAO" = "right" ]; then
    if [ "$active_right" -ge "$max_right" ]; then
        echo "Limite direito atingido. A mover janela para o próximo workspace..."
        hyprctl dispatch movetoworkspace r+1
    else
        echo "Ainda há espaço à direita. A mover janela apenas dentro do workspace..."
        # Opcional: Se quiseres que ela mude de posição com a da direita no mesmo workspace
        hyprctl dispatch swapwindow r
    fi
elif [ "$DIRECAO" = "left" ]; then
    if [ "$active_x" -le "$min_left" ]; then
        echo "Limite esquerdo atingido. A mover janela para o workspace anterior..."
        hyprctl dispatch movetoworkspace r-1
    else
        echo "Ainda há espaço à esquerda. A mover janela apenas dentro do workspace..."
        # Opcional: Inverte com a janela da esquerda
        hyprctl dispatch swapwindow l
    fi
else
    echo "Por favor, passa 'right' ou 'left' como argumento."
    exit 1
fi