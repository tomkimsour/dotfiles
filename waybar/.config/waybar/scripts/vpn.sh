#!/usr/bin/env bash
# VPN status + control for waybar via nmcli (+ rofi picker).
# Usage: vpn.sh status | trigger | toggle
list_vpns()   { nmcli -t -f NAME,TYPE connection show 2>/dev/null        | awk -F: '$2=="vpn"||$2=="wireguard"{print $1}'; }
active_vpns() { nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2=="vpn"||$2=="wireguard"{print $1}'; }

case "${1:-status}" in
  status)
    a=$(active_vpns | head -n1)
    if [ -n "$a" ]; then
      printf '{"text":"󰦝","tooltip":"VPN: %s","class":"connected"}\n' "$a"
    else
      printf '{"text":"󰦞","tooltip":"VPN: off","class":"disconnected"}\n'
    fi ;;
  trigger)
    if [ -n "$(active_vpns | head -n1)" ]; then
      printf '{"text":"󰘮","tooltip":"Quick settings \u2014 VPN on","class":"vpn-active"}\n'
    else
      printf '{"text":"󰘮","tooltip":"Quick settings","class":""}\n'
    fi ;;
  toggle)
    mapfile -t all < <(list_vpns)
    if [ ${#all[@]} -eq 0 ]; then notify-send "VPN" "No VPN connections defined"; exit 0; fi
    active=" $(active_vpns | tr '\n' ' ') "
    menu=""
    for v in "${all[@]}"; do
      case "$active" in
        *" $v "*) menu+="󰦝  $v"$'\n' ;;
        *)        menu+="󰦞  $v"$'\n' ;;
      esac
    done
    choice=$(printf '%s' "$menu" | rofi -dmenu -i -p "VPN" | sed 's/^[^ ]*  //')
    [ -z "$choice" ] && exit 0
    case "$active" in
      *" $choice "*) nmcli connection down "$choice" ;;
      *)             nmcli connection up   "$choice" ;;
    esac
    pkill -RTMIN+11 waybar 2>/dev/null || true ;;
esac
