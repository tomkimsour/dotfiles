#!/usr/bin/env bash
# Interactive Bluetooth menu for waybar via bluetoothctl + rofi.
#   menu  -> power toggle + device list (connect/disconnect/pair), loops until Escape
#   dump  -> print the menu it would build (for testing, no rofi needed)
# The built-in waybar `bluetooth` module updates itself over DBus, so no signal is sent.

DIV="──────────────────"

powered() { bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }

dev_state() {  # MAC -> connected | paired | new
  local info; info=$(bluetoothctl info "$1" 2>/dev/null)
  if   grep -q "Connected: yes" <<<"$info"; then echo connected
  elif grep -q "Paired: yes"    <<<"$info"; then echo paired
  else echo new; fi
}

build_lines() {  # fills LINES[] and MAC_OF[label]=mac in the current shell
  LINES=(); declare -gA MAC_OF=()
  if powered; then
    LINES+=("Bluetooth: On   (select to turn off)")
    while read -r _ mac name; do
      [ -z "$mac" ] && continue
      case "$(dev_state "$mac")" in
        connected) lbl="●  ${name}   (connected)" ;;
        paired)    lbl="○  ${name}   (paired)" ;;
        *)         lbl="·  ${name}" ;;
      esac
      LINES+=("$lbl"); MAC_OF["$lbl"]="$mac"
    done < <(bluetoothctl devices 2>/dev/null | sort -k3)
    LINES+=("$DIV")
    LINES+=("Scan for devices")
  else
    LINES+=("Bluetooth: Off   (select to turn on)")
  fi
}

if ! command -v bluetoothctl >/dev/null; then
  notify-send -u critical "Bluetooth" "bluetoothctl not found"; exit 1
fi

case "${1:-menu}" in
  dump)
    build_lines
    printf '%s\n' "${LINES[@]}"
    echo "---- label -> mac ----"
    for k in "${!MAC_OF[@]}"; do echo "$k => ${MAC_OF[$k]}"; done
    ;;
  menu)
    while true; do
      build_lines
      choice=$(printf '%s\n' "${LINES[@]}" | rofi -dmenu -i -p "Bluetooth")
      [ -z "$choice" ] && break
      case "$choice" in
        "Bluetooth: On"*)   bluetoothctl power off >/dev/null ;;
        "Bluetooth: Off"*)  bluetoothctl power on  >/dev/null; sleep 1 ;;
        "Scan for devices") notify-send -u low Bluetooth "Scanning for 8s…"
                            bluetoothctl --timeout 8 scan on >/dev/null 2>&1 ;;
        "$DIV")             : ;;
        *)
          mac="${MAC_OF[$choice]:-}"
          [ -z "$mac" ] && continue
          case "$(dev_state "$mac")" in
            connected) bluetoothctl disconnect "$mac" >/dev/null 2>&1 \
                         && notify-send -u low Bluetooth "Disconnected ${choice#*  }" ;;
            paired)    bluetoothctl connect "$mac" >/dev/null 2>&1 \
                         && notify-send -u low Bluetooth "Connected ${choice#*  }" \
                         || notify-send -u critical Bluetooth "Could not connect" ;;
            *)         notify-send -u low Bluetooth "Pairing…"
                       bluetoothctl pair "$mac"    >/dev/null 2>&1
                       bluetoothctl trust "$mac"   >/dev/null 2>&1
                       bluetoothctl connect "$mac" >/dev/null 2>&1 \
                         && notify-send -u low Bluetooth "Connected ${choice#*  }" ;;
          esac ;;
      esac
    done
    ;;
esac
