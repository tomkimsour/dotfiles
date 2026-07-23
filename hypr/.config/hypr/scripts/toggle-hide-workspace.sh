#!/usr/bin/env bash
# Show-desktop toggle: hides all windows on the active workspace by moving
# them into a special workspace, and restores them back on the next press.
set -euo pipefail

special="special:hidden_ws"
active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
hidden_clients=$(hyprctl clients -j | jq -c '[.[] | select(.workspace.name == "special:hidden_ws")]')

if [ "$(echo "$hidden_clients" | jq 'length')" -gt 0 ]; then
    echo "$hidden_clients" | jq -r '.[].address' | while read -r addr; do
        hyprctl dispatch movetoworkspacesilent "$active_ws,address:$addr"
    done
else
    hyprctl clients -j \
        | jq -r --arg ws "$active_ws" '.[] | select(.workspace.id == ($ws | tonumber)) | .address' \
        | while read -r addr; do
            hyprctl dispatch movetoworkspacesilent "$special,address:$addr"
        done
fi
