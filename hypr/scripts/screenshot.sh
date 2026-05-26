#!/usr/bin/env bash

# 1. Verificar se o scratchpad "global" está visível no monitor focado
is_open=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .specialWorkspace.name')

# 2. Contar quantas janelas existem no scratchpad "global"
cnt=$(hyprctl workspaces -j | jq -r '.[] | select(.name=="special:global") | .windows')

# Se estiver aberto E estiver vazio (sem janelas), fecha-o antes de tirar o print
if [ "$is_open" = "special:global" ] && { [ -z "$cnt" ] || [ "$cnt" -eq 0 ]; }; then
    hyprctl dispatch togglespecialworkspace global
    sleep 0.15 # Tempo ligeiramente maior para garantir que a animação de fecho terminou
fi

# 3. Executar o screenshot normal
killall -9 slurp 2>/dev/null || true
grim -g "$(slurp)" - | wl-copy
